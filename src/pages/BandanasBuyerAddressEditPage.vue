<template>
  <q-page padding class="bg-grey-1 bandanas-page">
    <div class="row items-center q-mb-md">
      <q-btn
        flat
        icon="arrow_back"
        :label="route.query.buyerId ? 'Back to Buyer' : 'Back to Addresses'"
        @click="handleBack"
      />
    </div>

    <q-card>
      <q-card-section>
        <div class="text-h6">
          {{ isNew ? 'Add Address' : 'Edit Address' }}
        </div>
      </q-card-section>

      <q-card-section>
        <div class="row q-col-gutter-md">
          <div class="col-12">
            <q-select
              v-model="form.buyer_id"
              :options="buyerOptions"
              option-value="id"
              option-label="label"
              label="Buyer *"
              outlined
              :error="!form.buyer_id"
              error-message="Buyer is required"
              :loading="buyersStore.loading.value"
              @update:model-value="loadBuyers"
            />
          </div>
          <div class="col-12">
            <q-select
              v-model="selectedAddress"
              :options="addressSuggestions"
              option-value="id"
              option-label="fullAddress"
              use-input
              hide-selected
              fill-input
              input-debounce="300"
              label="Search Address (Mapbox)"
              outlined
              :loading="mapboxLoading"
              @filter="handleAddressFilter"
              @update:model-value="selectAddress"
            >
              <template v-slot:prepend>
                <q-icon name="search" />
              </template>
              <template v-slot:no-option>
                <q-item>
                  <q-item-section class="text-grey">
                    Start typing an address (min 3 characters)
                  </q-item-section>
                </q-item>
              </template>
              <template v-slot:option="scope">
                <q-item v-bind="scope.itemProps">
                  <q-item-section>
                    <q-item-label>{{ scope.opt.fullAddress }}</q-item-label>
                  </q-item-section>
                </q-item>
              </template>
            </q-select>
            <div class="text-caption text-grey-7 q-mt-xs">
              Search for an address to auto-fill the fields below
            </div>
          </div>
          <div class="col-12">
            <q-input
              v-model="form.address_line1"
              label="Address Line 1 *"
              outlined
              :error="!form.address_line1"
              error-message="Address line 1 is required"
            />
          </div>
          <div class="col-12">
            <q-input
              v-model="form.address_line2"
              label="Address Line 2"
              outlined
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model="form.city"
              label="City *"
              outlined
              :error="!form.city"
              error-message="City is required"
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model="form.state"
              label="State"
              outlined
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model="form.postal_code"
              label="Postal Code *"
              outlined
              :error="!form.postal_code"
              error-message="Postal code is required"
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model="form.country"
              label="Country *"
              outlined
              :error="!form.country"
              error-message="Country is required"
            />
          </div>
        </div>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn
          flat
          label="Cancel"
          @click="handleBack"
        />
        <q-btn
          color="purple"
          label="Save"
          :loading="saving"
          @click="handleSave"
        />
      </q-card-actions>
    </q-card>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useBuyerAddressesStore } from 'src/stores/bandanas/buyerAddresses'
import { useBuyersStore } from 'src/stores/bandanas/buyers'
import { useQuasar } from 'quasar'
import { useMapboxGeocoding } from 'src/composables/useMapboxGeocoding'

const router = useRouter()
const route = useRoute()
const $q = useQuasar()
const addressesStore = useBuyerAddressesStore()
const buyersStore = useBuyersStore()
const { isLoading: mapboxLoading, searchAddresses } = useMapboxGeocoding()

const isNew = ref(true)
const saving = ref(false)
const addressSearch = ref('')
const selectedAddress = ref(null)
const addressSuggestions = ref([])

const form = ref({
  buyer_id: null,
  address_line1: '',
  address_line2: '',
  city: '',
  state: '',
  postal_code: '',
  country: 'US',
})

const buyerOptions = computed(() => {
  return buyersStore.buyers.value.map((b) => ({
    id: b.id,
    label: `${b.first_name} ${b.last_name}${b.email ? ' (' + b.email + ')' : ''}`,
  }))
})

function handleBack() {
  if (route.query.buyerId) {
    router.push({ name: 'bandanas-buyer-detail', params: { id: route.query.buyerId } })
  } else {
    router.push({ name: 'bandanas-addresses' })
  }
}

async function loadBuyers() {
  if (buyersStore.buyers.value.length === 0) {
    await buyersStore.refetch()
  }
}

// Mapbox address search
async function handleAddressFilter(val, update) {
  if (val.length < 3) {
    update(() => {
      addressSuggestions.value = []
    })
    return
  }

  addressSearch.value = val
  const suggestions = await searchAddresses(val, { country: form.value.country || 'US' })
  update(() => {
    addressSuggestions.value = suggestions
  })
}

function selectAddress(address) {
  if (address) {
    form.value.address_line1 = address.addressLine1 || ''
    form.value.address_line2 = address.addressLine2 || ''
    form.value.city = address.city || ''
    form.value.state = address.state || ''
    form.value.postal_code = address.postalCode || ''
    form.value.country = address.country || 'US'
    addressSearch.value = address.fullAddress
  }
}

onMounted(async () => {
  await loadBuyers()
  const id = route.params.id
  if (id && id !== 'new') {
    isNew.value = false
    // Fetch address data
    await addressesStore.refetch()
    const address = addressesStore.buyerAddresses.value.find((a) => a.id === id)
    if (address) {
      form.value = {
        buyer_id: address.buyer_id,
        address_line1: address.address_line1 || '',
        address_line2: address.address_line2 || '',
        city: address.city || '',
        state: address.state || '',
        postal_code: address.postal_code || '',
        country: address.country || 'US',
      }
    }
  } else if (id === 'new' && route.query.buyerId) {
    // Pre-fill buyer_id if provided in query params
    form.value.buyer_id = route.query.buyerId
  }
})

async function handleSave() {
  if (!form.value.buyer_id || !form.value.address_line1 || !form.value.city || !form.value.postal_code || !form.value.country) {
    $q.notify({
      type: 'negative',
      message: 'Please fill in all required fields',
    })
    return
  }

  saving.value = true
  try {
    if (isNew.value) {
      await addressesStore.createBuyerAddress({
        buyer_id: form.value.buyer_id,
        address_line1: form.value.address_line1,
        address_line2: form.value.address_line2 || null,
        city: form.value.city,
        state: form.value.state || null,
        postal_code: form.value.postal_code,
        country: form.value.country,
      })
      $q.notify({
        type: 'positive',
        message: 'Address created successfully',
      })
    } else {
      await addressesStore.updateBuyerAddress(route.params.id, {
        buyer_id: form.value.buyer_id,
        address_line1: form.value.address_line1,
        address_line2: form.value.address_line2 || null,
        city: form.value.city,
        state: form.value.state || null,
        postal_code: form.value.postal_code,
        country: form.value.country,
      })
      $q.notify({
        type: 'positive',
        message: 'Address updated successfully',
      })
    }
    if (route.query.buyerId) {
      router.push({ name: 'bandanas-buyer-detail', params: { id: route.query.buyerId } })
    } else {
      router.push({ name: 'bandanas-addresses' })
    }
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Error saving address: ' + error.message,
    })
  } finally {
    saving.value = false
  }
}
</script>

