<template>
  <q-page padding class="bg-grey-1 bandanas-page">
    <div class="row items-center q-mb-md">
      <q-btn
        flat
        icon="arrow_back"
        label="Back to Events"
        @click="router.push({ name: 'bandanas-events' })"
      />
    </div>

    <q-card>
      <q-card-section>
        <div class="text-h6">
          {{ isNew ? 'Add Event' : 'Edit Event' }}
        </div>
      </q-card-section>

      <q-card-section>
        <div class="row q-col-gutter-md">
          <div class="col-12 col-md-6">
            <q-input
              v-model="form.name"
              label="Event Name *"
              outlined
              :error="!form.name"
              error-message="Event name is required"
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.year"
              label="Year *"
              type="number"
              outlined
              :error="!form.year"
              error-message="Year is required"
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.price_single"
              label="Single Price *"
              type="number"
              step="0.01"
              prefix="$"
              outlined
              :error="form.price_single < 0"
              error-message="Price must be >= 0"
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.price_multi"
              label="Multi Price *"
              type="number"
              step="0.01"
              prefix="$"
              outlined
              :error="form.price_multi < 0"
              error-message="Price must be >= 0"
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.bandana_cost"
              label="Bandana Cost"
              type="number"
              step="0.01"
              prefix="$"
              outlined
              :error="form.bandana_cost !== null && form.bandana_cost < 0"
              error-message="Cost must be >= 0"
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.freight"
              label="Freight"
              type="number"
              step="0.01"
              prefix="$"
              outlined
              :error="form.freight !== null && form.freight < 0"
              error-message="Freight must be >= 0"
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.fee_tax_transaction_fees"
              label="Fee/Tax/Transaction Fees"
              type="number"
              step="0.01"
              prefix="$"
              outlined
              :error="form.fee_tax_transaction_fees !== null && form.fee_tax_transaction_fees < 0"
              error-message="Fee must be >= 0"
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.freight_out"
              label="Freight Out"
              type="number"
              step="0.01"
              prefix="$"
              outlined
              :error="form.freight_out !== null && form.freight_out < 0"
              error-message="Freight Out must be >= 0"
              hint="Freight costs for previous years (not added per line item)"
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.total_qty"
              label="Total Qty"
              type="number"
              outlined
              :error="form.total_qty !== null && form.total_qty < 0"
              error-message="Quantity must be >= 0"
            />
          </div>
          <div class="col-12">
            <q-toggle
              v-model="form.active"
              label="Active"
            />
          </div>
          <div class="col-12">
            <div class="text-subtitle2 q-mb-sm">Bandana Image</div>
            <q-file
              v-model="imageFile"
              label="Upload Image"
              accept="image/*"
              outlined
              :loading="uploadingImage"
              @update:model-value="handleImageUpload"
              clearable
            >
              <template v-slot:prepend>
                <q-icon name="image" />
              </template>
            </q-file>
            <div v-if="form.image_url" class="q-mt-md">
              <div class="text-caption text-grey-7 q-mb-xs">Current Image:</div>
              <img
                :src="form.image_url"
                alt="Bandana Image"
                style="width: 100%; max-width: 800px; height: auto; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);"
                class="q-mt-sm"
              />
            </div>
          </div>
        </div>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn
          flat
          label="Cancel"
          @click="router.push({ name: 'bandanas-events' })"
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
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useEventsStore } from 'src/stores/bandanas/events'
import { useQuasar } from 'quasar'
import { nhost } from 'boot/nhost'

const router = useRouter()
const route = useRoute()
const $q = useQuasar()
const eventsStore = useEventsStore()

const isNew = ref(true)
const saving = ref(false)
const uploadingImage = ref(false)

const form = ref({
  name: '',
  year: new Date().getFullYear(),
  price_single: 0,
  price_multi: 0,
  bandana_cost: null,
  freight: null,
  fee_tax_transaction_fees: null,
  freight_out: null,
  total_qty: null,
  active: true,
  image_url: null,
})

const imageFile = ref(null)

onMounted(async () => {
  const id = route.params.id
  if (id && id !== 'new') {
    isNew.value = false
    // Fetch event data
    const event = eventsStore.events.value.find((e) => e.id === id)
    if (event) {
      form.value = {
        name: event.name || '',
        year: event.year || new Date().getFullYear(),
        price_single: parseFloat(event.price_single) || 0,
        price_multi: parseFloat(event.price_multi) || 0,
        bandana_cost: event.bandana_cost ? parseFloat(event.bandana_cost) : null,
        freight: event.freight ? parseFloat(event.freight) : null,
        fee_tax_transaction_fees: event.fee_tax_transaction_fees ? parseFloat(event.fee_tax_transaction_fees) : null,
        freight_out: event.freight_out ? parseFloat(event.freight_out) : null,
        total_qty: event.total_qty || null,
        active: event.active !== false,
        image_url: event.image_url || null,
      }
    } else {
      // If not found, wait for store to load and try again
      await eventsStore.refetch()
      const eventAfterRefetch = eventsStore.events.value.find((e) => e.id === id)
      if (eventAfterRefetch) {
        form.value = {
          name: eventAfterRefetch.name || '',
          year: eventAfterRefetch.year || new Date().getFullYear(),
          price_single: parseFloat(eventAfterRefetch.price_single) || 0,
          price_multi: parseFloat(eventAfterRefetch.price_multi) || 0,
        bandana_cost: eventAfterRefetch.bandana_cost ? parseFloat(eventAfterRefetch.bandana_cost) : null,
        freight: eventAfterRefetch.freight ? parseFloat(eventAfterRefetch.freight) : null,
        fee_tax_transaction_fees: eventAfterRefetch.fee_tax_transaction_fees ? parseFloat(eventAfterRefetch.fee_tax_transaction_fees) : null,
        freight_out: eventAfterRefetch.freight_out ? parseFloat(eventAfterRefetch.freight_out) : null,
        total_qty: eventAfterRefetch.total_qty || null,
        active: eventAfterRefetch.active !== false,
        image_url: eventAfterRefetch.image_url || null,
      }
      }
    }
  }
})

async function handleSave() {
  if (!form.value.name || !form.value.year) {
    $q.notify({
      type: 'negative',
      message: 'Event name and year are required',
    })
    return
  }

  if (form.value.price_single < 0 || form.value.price_multi < 0) {
    $q.notify({
      type: 'negative',
      message: 'Prices must be >= 0',
    })
    return
  }

  if (
    (form.value.bandana_cost !== null && form.value.bandana_cost < 0) ||
    (form.value.freight !== null && form.value.freight < 0) ||
    (form.value.fee_tax_transaction_fees !== null && form.value.fee_tax_transaction_fees < 0) ||
    (form.value.freight_out !== null && form.value.freight_out < 0) ||
    (form.value.total_qty !== null && form.value.total_qty < 0)
  ) {
    $q.notify({
      type: 'negative',
      message: 'All numeric fields must be >= 0',
    })
    return
  }

  saving.value = true
  try {
    if (isNew.value) {
      await eventsStore.createEvent({
        name: form.value.name,
        year: form.value.year,
        price_single: form.value.price_single,
        price_multi: form.value.price_multi,
        bandana_cost: form.value.bandana_cost ?? null,
        freight: form.value.freight ?? null,
        fee_tax_transaction_fees: form.value.fee_tax_transaction_fees ?? null,
        freight_out: form.value.freight_out ?? null,
        total_qty: form.value.total_qty ?? null,
        active: form.value.active,
        image_url: form.value.image_url ?? null,
      })
      $q.notify({
        type: 'positive',
        message: 'Event created successfully',
      })
    } else {
      await eventsStore.updateEvent(route.params.id, {
        name: form.value.name,
        year: form.value.year,
        price_single: form.value.price_single,
        price_multi: form.value.price_multi,
        bandana_cost: form.value.bandana_cost ?? null,
        freight: form.value.freight ?? null,
        fee_tax_transaction_fees: form.value.fee_tax_transaction_fees ?? null,
        freight_out: form.value.freight_out ?? null,
        total_qty: form.value.total_qty ?? null,
        active: form.value.active,
        image_url: form.value.image_url ?? null,
      })
      $q.notify({
        type: 'positive',
        message: 'Event updated successfully',
      })
    }
    router.push({ name: 'bandanas-events' })
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Error saving event: ' + error.message,
    })
  } finally {
    saving.value = false
  }
}

async function handleImageUpload(file) {
  if (!file) {
    form.value.image_url = null
    return
  }

  uploadingImage.value = true

  try {
    // Upload file to Nhost storage
    const { fileMetadata, error: uploadError } = await nhost.storage.upload({
      file,
      bucketId: 'default',
      options: { public: true },
    })

    if (uploadError) {
      throw uploadError
    }

    // Get public URL
    const url = nhost.storage.getPublicUrl({ fileId: fileMetadata.id })
    form.value.image_url = url

    $q.notify({
      type: 'positive',
      message: 'Image uploaded successfully',
    })
  } catch (error) {
    console.error('Image upload failed:', error)
    $q.notify({
      type: 'negative',
      message: 'Error uploading image: ' + (error.message || 'Unknown error'),
    })
    imageFile.value = null
    form.value.image_url = null
  } finally {
    uploadingImage.value = false
  }
}
</script>

