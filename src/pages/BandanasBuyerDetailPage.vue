<template>
  <q-page padding class="bg-grey-1 bandanas-page">
    <div class="row items-center q-mb-md">
      <q-btn
        flat
        icon="arrow_back"
        label="Back to Orders"
        @click="router.push({ name: 'bandanas-orders' })"
      />
    </div>

    <!-- Buyer Information Card -->
    <q-card class="q-mb-md">
      <q-card-section>
        <div class="text-h6">Buyer Information</div>
      </q-card-section>
      <q-card-section>
        <div class="row q-col-gutter-md">
          <div class="col-12 col-md-6">
            <q-input
              v-model="buyerForm.first_name"
              label="First Name *"
              outlined
              :error="!buyerForm.first_name"
              error-message="First name is required"
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model="buyerForm.last_name"
              label="Last Name *"
              outlined
              :error="!buyerForm.last_name"
              error-message="Last name is required"
            />
          </div>
          <div class="col-12">
            <q-input
              v-model="buyerForm.email"
              label="Email"
              type="email"
              outlined
            />
          </div>
        </div>
      </q-card-section>
      <q-card-actions align="right">
        <q-btn
          color="purple"
          label="Save Buyer Info"
          :loading="savingBuyer"
          @click="handleSaveBuyer"
        />
      </q-card-actions>
    </q-card>

    <!-- Past Orders -->
    <q-card class="q-mb-md">
      <q-card-section>
        <div class="text-h6">Past Orders ({{ buyerOrders.length }})</div>
      </q-card-section>
      <q-card-section v-if="buyerOrders.length === 0">
        <div class="text-grey-7 text-center q-pa-md">No orders found for this buyer</div>
      </q-card-section>
      <q-card-section v-else>
        <div class="row q-col-gutter-md">
          <div
            v-for="order in buyerOrders"
            :key="order.id"
            class="col-12 col-md-6 col-lg-4"
          >
            <q-card
              class="cursor-pointer order-card"
              @click="router.push({ name: 'bandanas-order-edit', params: { id: order.id } })"
            >
              <q-card-section>
                <div class="row items-center justify-between q-mb-sm">
                  <div class="text-subtitle1 text-weight-bold">
                    {{ order.event?.name }} ({{ order.event?.year }})
                  </div>
                  <q-chip
                    :color="getStatusColor(order.status)"
                    text-color="white"
                    size="sm"
                  >
                    {{ order.status || 'Ordered' }}
                  </q-chip>
                </div>
                <div class="text-caption text-grey-7 q-mb-xs">
                  {{ new Date(order.order_date).toLocaleDateString() }}
                </div>
                <div class="row q-col-gutter-sm q-mt-sm">
                  <div class="col-6">
                    <div class="text-caption text-grey-7">Qty</div>
                    <div class="text-body2">{{ order.quantity }}</div>
                  </div>
                  <div class="col-6">
                    <div class="text-caption text-grey-7">Total Paid</div>
                    <div class="text-body2 text-weight-medium">${{ parseFloat(order.amount_paid || 0).toFixed(2) }}</div>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>
        </div>
      </q-card-section>
    </q-card>

    <!-- Addresses -->
    <q-card>
      <q-card-section>
        <div class="row items-center justify-between">
          <div class="text-h6">Addresses ({{ buyerAddresses.length }})</div>
          <q-btn
            color="purple"
            icon="add"
            label="Add Address"
            @click="router.push({ name: 'bandanas-address-edit', params: { id: 'new' }, query: { buyerId: buyerId } })"
          />
        </div>
      </q-card-section>
      <q-card-section v-if="buyerAddresses.length === 0">
        <div class="text-grey-7 text-center q-pa-md">No addresses found for this buyer</div>
      </q-card-section>
      <q-card-section v-else>
        <div class="row q-col-gutter-md">
          <div
            v-for="address in buyerAddresses"
            :key="address.id"
            class="col-12 col-md-6"
          >
            <q-card
              class="cursor-pointer address-card"
              @click="router.push({ name: 'bandanas-address-edit', params: { id: address.id } })"
            >
              <q-card-section>
                <div class="row items-center justify-between">
                  <div class="col">
                    <div class="text-body1 text-weight-medium q-mb-xs">
                      {{ address.address_line1 }}
                    </div>
                    <div v-if="address.address_line2" class="text-body2 q-mb-xs">
                      {{ address.address_line2 }}
                    </div>
                    <div class="text-body2">
                      {{ address.city }}{{ address.state ? ', ' + address.state : '' }}
                      {{ address.postal_code }}
                    </div>
                    <div class="text-caption text-grey-7">{{ address.country }}</div>
                  </div>
                  <q-btn
                    flat
                    round
                    icon="edit"
                    color="purple"
                    @click.stop="router.push({ name: 'bandanas-address-edit', params: { id: address.id } })"
                  />
                </div>
              </q-card-section>
            </q-card>
          </div>
        </div>
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useBuyersStore } from 'src/stores/bandanas/buyers'
import { useOrdersStore } from 'src/stores/bandanas/orders'
import { useBuyerAddressesStore } from 'src/stores/bandanas/buyerAddresses'
import { useQuasar } from 'quasar'

const router = useRouter()
const route = useRoute()
const $q = useQuasar()
const buyersStore = useBuyersStore()
const ordersStore = useOrdersStore()
const addressesStore = useBuyerAddressesStore()

const buyerId = computed(() => route.params.id)
const savingBuyer = ref(false)

const buyerForm = ref({
  first_name: '',
  last_name: '',
  email: '',
})

// Get buyer orders
const buyerOrders = computed(() => {
  if (!buyerId.value) return []
  return ordersStore.orders.value
    .filter((order) => order.buyer_id === buyerId.value)
    .sort((a, b) => new Date(b.order_date) - new Date(a.order_date))
})

// Get buyer addresses
const buyerAddresses = computed(() => {
  if (!buyerId.value) return []
  return addressesStore.buyerAddresses.value.filter(
    (address) => address.buyer_id === buyerId.value
  )
})

function getStatusColor(status) {
  switch (status) {
    case 'Ordered':
      return 'orange'
    case 'Shipped':
      return 'blue'
    case 'Received':
      return 'positive'
    case 'Other':
      return 'grey'
    default:
      return 'orange'
  }
}

async function handleSaveBuyer() {
  if (!buyerForm.value.first_name || !buyerForm.value.last_name) {
    $q.notify({
      type: 'negative',
      message: 'First name and last name are required',
    })
    return
  }

  savingBuyer.value = true
  try {
    await buyersStore.updateBuyer(buyerId.value, {
      first_name: buyerForm.value.first_name.trim(),
      last_name: buyerForm.value.last_name.trim(),
      email: buyerForm.value.email?.trim() || null,
    })
    $q.notify({
      type: 'positive',
      message: 'Buyer information updated successfully',
    })
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Error updating buyer: ' + error.message,
    })
  } finally {
    savingBuyer.value = false
  }
}

async function loadBuyerData() {
  // Load all data
  await Promise.all([
    buyersStore.refetch(),
    ordersStore.refetch(),
    addressesStore.refetch(),
  ])

  // Load buyer data
  const buyer = buyersStore.buyers.value.find((b) => b.id === buyerId.value)
  if (buyer) {
    buyerForm.value = {
      first_name: buyer.first_name || '',
      last_name: buyer.last_name || '',
      email: buyer.email || '',
    }
  } else {
    $q.notify({
      type: 'negative',
      message: 'Buyer not found',
    })
    router.push({ name: 'bandanas-orders' })
  }
}

onMounted(() => {
  loadBuyerData()
})

// Watch for route changes to refresh data
watch(() => route.params.id, () => {
  loadBuyerData()
})
</script>

<style scoped>
.order-card:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  transition: box-shadow 0.2s;
}

.address-card:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  transition: box-shadow 0.2s;
}
</style>

