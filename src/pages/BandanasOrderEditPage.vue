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

    <q-card>
      <q-card-section>
        <div class="text-h6">
          {{ isNew ? 'Add Order' : 'Edit Order' }}
        </div>
      </q-card-section>

      <q-card-section>
        <div class="row q-col-gutter-md">
          <!-- Buyer Search with Autocomplete -->
          <div class="col-12">
            <q-select
              v-model="selectedBuyer"
              :options="filteredBuyerOptions"
              use-input
              input-debounce="300"
              @filter="filterBuyers"
              option-value="id"
              option-label="label"
              emit-value
              map-options
              label="Search Buyer by Name *"
              outlined
              :error="!form.buyer_id"
              error-message="Buyer is required"
              :loading="buyersStore.loading.value"
              @update:model-value="handleBuyerSelect"
            >
              <template v-slot:no-option>
                <q-item>
                  <q-item-section class="text-grey">
                    No buyers found. Type to search or create new.
                  </q-item-section>
                </q-item>
              </template>
              <template v-slot:option="scope">
                <q-item v-bind="scope.itemProps">
                  <q-item-section>
                    <q-item-label>{{ scope.opt.label }}</q-item-label>
                    <q-item-label v-if="scope.opt.email" caption>
                      {{ scope.opt.email }}
                    </q-item-label>
                  </q-item-section>
                </q-item>
              </template>
            </q-select>
            <div class="row q-mt-sm">
              <q-btn
                flat
                dense
                color="purple"
                icon="add"
                label="Create New Buyer"
                @click="showCreateBuyerDialog = true"
              />
            </div>
          </div>

          <!-- Past Orders for Selected Buyer -->
          <div v-if="form.buyer_id && buyerPastOrders.length > 0" class="col-12 q-mt-md">
            <div class="text-subtitle2 text-weight-medium q-mb-sm">
              Past Orders ({{ buyerPastOrders.length }})
            </div>
            <div class="row q-col-gutter-sm">
              <div
                v-for="order in buyerPastOrders"
                :key="order.id"
                class="col-12 col-sm-6 col-md-4"
              >
                <q-card
                  class="cursor-pointer past-order-card"
                  @click="router.push({ name: 'bandanas-order-edit', params: { id: order.id } })"
                >
                  <q-card-section class="q-pa-sm">
                    <div class="row items-center justify-between q-mb-xs">
                      <div class="text-body2 text-weight-medium">
                        {{ order.event?.name }} ({{ order.event?.year }})
                      </div>
                      <q-chip :color="getStatusColor(order.status)" text-color="white" size="xs">
                        {{ order.status || 'Ordered' }}
                      </q-chip>
                    </div>
                    <div class="text-caption text-grey-7 q-mb-xs">
                      {{ new Date(order.order_date).toLocaleDateString() }}
                    </div>
                    <div class="row q-col-gutter-xs">
                      <div class="col-6">
                        <div class="text-caption text-grey-7">Qty</div>
                        <div class="text-body2">{{ order.quantity }}</div>
                      </div>
                      <div class="col-6">
                        <div class="text-caption text-grey-7">Paid</div>
                        <div class="text-body2 text-weight-medium">
                          ${{ parseFloat(order.amount_paid || 0).toFixed(2) }}
                        </div>
                      </div>
                    </div>
                  </q-card-section>
                </q-card>
              </div>
            </div>
          </div>

          <!-- Event Selection -->
          <div class="col-12 col-md-6">
            <q-select
              v-model="form.event_id"
              :options="eventOptions"
              option-value="id"
              option-label="label"
              emit-value
              map-options
              label="Event *"
              outlined
              :error="!form.event_id"
              error-message="Event is required"
              :loading="eventsStore.loading.value"
              @update:model-value="handleEventSelect"
            />
          </div>

          <!-- Order Date -->
          <div class="col-12 col-md-6">
            <q-input
              v-model="form.order_date"
              label="Order Date *"
              type="datetime-local"
              outlined
            />
          </div>

          <!-- Address Selection (only shown if buyer is selected) -->
          <div v-if="form.buyer_id" class="col-12">
            <q-select
              v-model="form.address_id"
              :options="addressOptions"
              option-value="id"
              option-label="label"
              emit-value
              map-options
              label="Shipping Address"
              outlined
              clearable
              :loading="addressesStore.loading.value"
            >
              <template v-slot:append>
                <q-btn
                  flat
                  dense
                  round
                  icon="add"
                  color="purple"
                  @click="showCreateAddressDialog = true"
                />
              </template>
            </q-select>
            <div class="text-caption text-grey-7 q-mt-xs">
              Select an address or click + to create a new one
            </div>
          </div>

          <!-- Quantity -->
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.quantity"
              label="Quantity *"
              type="number"
              outlined
              :error="form.quantity <= 0"
              error-message="Quantity must be > 0"
              @update:model-value="calculatePrice"
            />
          </div>

          <!-- Total Price (auto-calculated) -->
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.total_price"
              label="Total Price *"
              type="number"
              step="0.01"
              prefix="$"
              outlined
              :error="form.total_price < 0"
              error-message="Price must be >= 0"
              readonly
              :hint="priceHint"
            />
          </div>

          <!-- Amount Paid -->
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.amount_paid"
              label="Amount Paid *"
              type="number"
              step="0.01"
              prefix="$"
              outlined
              :error="form.amount_paid < 0"
              error-message="Amount must be >= 0"
            />
          </div>

          <!-- Fee -->
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.fee"
              label="Fee"
              type="number"
              step="0.01"
              prefix="$"
              outlined
              :error="form.fee < 0"
              error-message="Fee must be >= 0"
            />
          </div>

          <!-- Payment Method (How Paid) -->
          <div class="col-12 col-md-6">
            <q-input v-model="form.payment_method" label="How Paid" outlined />
          </div>

          <!-- Room Number -->
          <div class="col-12 col-md-6">
            <q-input v-model="form.room_number" label="Room Number" outlined />
          </div>

          <!-- Order Number -->
          <div class="col-12 col-md-6">
            <q-input
              v-model="form.order_number"
              label="Order Number"
              outlined
              hint="Unique identifier for shipping/import matching"
            />
          </div>

          <!-- Tracking Number -->
          <div class="col-12 col-md-6">
            <q-input
              v-model="form.tracking_number"
              label="Tracking Number"
              outlined
              hint="Shipping tracking number"
            />
          </div>

          <!-- Status -->
          <div class="col-12 col-md-6">
            <q-select
              v-model="form.status"
              :options="statusOptions"
              label="Status *"
              outlined
              :error="!form.status"
              error-message="Status is required"
            />
          </div>

          <!-- USPS Zone -->
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.usps_zone"
              label="USPS Zone"
              type="number"
              outlined
              readonly
              :loading="zoneLoading"
              hint="Auto-calculated from shipping address"
            >
              <template v-slot:prepend>
                <q-icon name="local_shipping" />
              </template>
            </q-input>
          </div>

          <!-- Package Dimensions (Auto-filled based on quantity) -->
          <div class="col-12">
            <div class="text-subtitle2 q-mb-sm">Package Dimensions (inches)</div>
            <div class="row q-col-gutter-md">
              <div class="col-12 col-md-3">
                <q-input
                  v-model.number="form.length"
                  label="Length"
                  type="number"
                  step="0.01"
                  outlined
                  readonly
                  hint="Auto-calculated from quantity"
                />
              </div>
              <div class="col-12 col-md-3">
                <q-input
                  v-model.number="form.width"
                  label="Width"
                  type="number"
                  step="0.01"
                  outlined
                  readonly
                />
              </div>
              <div class="col-12 col-md-3">
                <q-input
                  v-model.number="form.height"
                  label="Height"
                  type="number"
                  step="0.01"
                  outlined
                  readonly
                />
              </div>
              <div class="col-12 col-md-3">
                <q-input
                  v-model.number="form.weight"
                  label="Weight (oz)"
                  type="number"
                  step="0.01"
                  outlined
                  readonly
                />
              </div>
            </div>
          </div>

          <!-- Estimated Postage Cost -->
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.estimated_postage_cost"
              label="Estimated Postage Cost"
              type="number"
              step="0.01"
              prefix="$"
              outlined
              readonly
              hint="Auto-calculated from shipping rates table (zone + weight)"
            >
              <template v-slot:prepend>
                <q-icon name="attach_money" />
              </template>
            </q-input>
          </div>

          <!-- Actual Postage Cost -->
          <div class="col-12 col-md-6">
            <q-input
              v-model.number="form.actual_postage_cost"
              label="Actual Postage Cost"
              type="number"
              step="0.01"
              prefix="$"
              outlined
              hint="Enter the actual cost paid for shipping"
            >
              <template v-slot:prepend>
                <q-icon name="receipt" />
              </template>
            </q-input>
          </div>

          <!-- Notes -->
          <div class="col-12">
            <q-input v-model="form.notes" label="Notes" type="textarea" outlined rows="3" />
          </div>
        </div>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn flat label="Cancel" @click="router.push({ name: 'bandanas-orders' })" />
        <q-btn color="purple" label="Save" :loading="saving" @click="handleSave" />
      </q-card-actions>
    </q-card>

    <!-- Create Buyer Dialog -->
    <q-dialog v-model="showCreateBuyerDialog" persistent>
      <q-card style="min-width: 400px">
        <q-card-section>
          <div class="text-h6">Create New Buyer</div>
        </q-card-section>
        <q-card-section>
          <q-input v-model="newBuyer.first_name" label="First Name *" outlined class="q-mb-md" />
          <q-input v-model="newBuyer.last_name" label="Last Name *" outlined class="q-mb-md" />
          <q-input v-model="newBuyer.email" label="Email" type="email" outlined />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="purple" @click="showCreateBuyerDialog = false" />
          <q-btn
            flat
            label="Create"
            color="purple"
            :loading="creatingBuyer"
            @click="handleCreateBuyer"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Create Address Dialog -->
    <q-dialog v-model="showCreateAddressDialog" persistent>
      <q-card style="min-width: 500px">
        <q-card-section>
          <div class="text-h6">Create New Address</div>
        </q-card-section>
        <q-card-section>
          <div class="col-12 q-mb-md">
            <q-select
              v-model="selectedMapboxAddress"
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
              @update:model-value="selectMapboxAddress"
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
          <q-input
            v-model="newAddress.address_line1"
            label="Address Line 1 *"
            outlined
            class="q-mb-md"
          />
          <q-input
            v-model="newAddress.address_line2"
            label="Address Line 2"
            outlined
            class="q-mb-md"
          />
          <div class="row q-col-gutter-md">
            <div class="col-12 col-md-6">
              <q-input v-model="newAddress.city" label="City *" outlined />
            </div>
            <div class="col-12 col-md-6">
              <q-input v-model="newAddress.state" label="State" outlined />
            </div>
          </div>
          <div class="row q-col-gutter-md q-mt-md">
            <div class="col-12 col-md-6">
              <q-input v-model="newAddress.postal_code" label="Postal Code *" outlined />
            </div>
            <div class="col-12 col-md-6">
              <q-input
                v-model="newAddress.country"
                label="Country *"
                outlined
                :value="newAddress.country || 'US'"
              />
            </div>
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="purple" @click="showCreateAddressDialog = false" />
          <q-btn
            flat
            label="Create"
            color="purple"
            :loading="creatingAddress"
            @click="handleCreateAddress"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useOrdersStore } from 'src/stores/bandanas/orders'
import { useBuyersStore } from 'src/stores/bandanas/buyers'
import { useEventsStore } from 'src/stores/bandanas/events'
import { useBuyerAddressesStore } from 'src/stores/bandanas/buyerAddresses'
import { useQuasar } from 'quasar'
import { useMapboxGeocoding } from 'src/composables/useMapboxGeocoding'
import { useUSPSZone } from 'src/composables/useUSPSZone'
import { getPackageDimensions } from 'src/composables/usePackageDimensions'
import { useShippingRatesStore } from 'src/stores/bandanas/shippingRates'

const router = useRouter()
const route = useRoute()
const $q = useQuasar()
const ordersStore = useOrdersStore()
const buyersStore = useBuyersStore()
const eventsStore = useEventsStore()
const addressesStore = useBuyerAddressesStore()
const shippingRatesStore = useShippingRatesStore()

const isNew = ref(true)
const saving = ref(false)
const selectedBuyer = ref(null)
const showCreateBuyerDialog = ref(false)
const showCreateAddressDialog = ref(false)
const creatingBuyer = ref(false)
const creatingAddress = ref(false)

// Mapbox address search
const { isLoading: mapboxLoading, searchAddresses } = useMapboxGeocoding()
const selectedMapboxAddress = ref(null)
const addressSuggestions = ref([])

// USPS Zone calculation
const { isLoading: zoneLoading, calculateZone } = useUSPSZone()

// Helper function to get current date/time in EST formatted for datetime-local input
function getCurrentESTDateTime() {
  const now = new Date()
  // Use Intl.DateTimeFormat to get EST time components
  const formatter = new Intl.DateTimeFormat('en-US', {
    timeZone: 'America/New_York',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  })

  const parts = formatter.formatToParts(now)
  const year = parts.find((p) => p.type === 'year')?.value
  const month = parts.find((p) => p.type === 'month')?.value
  const day = parts.find((p) => p.type === 'day')?.value
  const hour = parts.find((p) => p.type === 'hour')?.value
  const minute = parts.find((p) => p.type === 'minute')?.value

  return `${year}-${month}-${day}T${hour}:${minute}`
}

const form = ref({
  buyer_id: null,
  address_id: null,
  event_id: null,
  order_date: getCurrentESTDateTime(),
  quantity: 1,
  total_price: 0,
  amount_paid: 0,
  fee: 0,
  payment_method: '',
  room_number: '',
  order_number: null,
  tracking_number: '',
  status: 'Ordered',
  usps_zone: null,
  length: null,
  width: null,
  height: null,
  weight: null,
  estimated_postage_cost: null,
  actual_postage_cost: null,
  notes: '',
})

const statusOptions = [
  'Ordered',
  'Pending Shipping',
  'Tracking Created',
  'Shipped',
  'Received',
  'Other',
]

const newBuyer = ref({
  first_name: '',
  last_name: '',
  email: '',
})

const newAddress = ref({
  address_line1: '',
  address_line2: '',
  city: '',
  state: '',
  postal_code: '',
  country: 'US',
})

// Buyer options for autocomplete
const buyerOptions = computed(() => {
  return buyersStore.buyers.value.map((b) => ({
    id: b.id,
    label: `${b.first_name} ${b.last_name}`,
    email: b.email,
    searchText: `${b.first_name} ${b.last_name} ${b.email || ''}`.toLowerCase(),
  }))
})

const filteredBuyerOptions = ref(buyerOptions.value)

function filterBuyers(val, update) {
  if (val === '') {
    update(() => {
      filteredBuyerOptions.value = buyerOptions.value
    })
    return
  }

  update(() => {
    const needle = val.toLowerCase()
    filteredBuyerOptions.value = buyerOptions.value.filter((v) => v.searchText.indexOf(needle) > -1)
  })
}

function handleBuyerSelect(buyerId) {
  form.value.buyer_id = buyerId
  if (buyerId) {
    const buyer = buyersStore.buyers.value.find((b) => b.id === buyerId)
    if (buyer) {
      selectedBuyer.value = {
        id: buyer.id,
        label: `${buyer.first_name} ${buyer.last_name}`,
        email: buyer.email,
      }
    }
    // Load addresses for this buyer
    loadAddressesForBuyer()
    // Load orders for this buyer
    if (ordersStore.orders.value.length === 0) {
      ordersStore.refetch()
    }
  }
}

const eventOptions = computed(() => {
  return eventsStore.events.value.map((e) => ({
    id: e.id,
    label: `${e.name} (${e.year})`,
  }))
})

// Get past orders for selected buyer
const buyerPastOrders = computed(() => {
  if (!form.value.buyer_id) return []
  return ordersStore.orders.value
    .filter((order) => order.buyer_id === form.value.buyer_id && order.id !== route.params.id)
    .sort((a, b) => new Date(b.order_date) - new Date(a.order_date))
    .slice(0, 12) // Limit to 12 most recent orders
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

const selectedEvent = computed(() => {
  if (!form.value.event_id) return null
  return eventsStore.events.value.find((e) => e.id === form.value.event_id)
})

// Generate order number: EventName-#### (e.g., JC22-0001)
// Numbers increment globally across all events, not per event
async function generateOrderNumber() {
  if (!form.value.event_id) return

  const event = selectedEvent.value
  if (!event) return

  try {
    // Get all existing orders to find the highest number globally
    await ordersStore.refetch()
    const allOrders = ordersStore.orders.value

    // Extract all order numbers that match the pattern EventName-####
    // and find the highest number across ALL events
    const orderNumbers = allOrders
      .map((o) => o.order_number)
      .filter((num) => num && num.match(/^[A-Z0-9]+-\d+$/)) // Match any EventName-#### pattern
      .map((num) => {
        const match = num.match(/-(\d+)$/)
        return match ? parseInt(match[1], 10) : 0
      })

    // Find the highest number globally and increment
    const maxNumber = orderNumbers.length > 0 ? Math.max(...orderNumbers) : 0
    const nextNumber = maxNumber + 1

    // Format as EventName-#### (4 digits with leading zeros)
    // Use the current event's prefix with the next global number
    const eventPrefix = event.name
    form.value.order_number = `${eventPrefix}-${String(nextNumber).padStart(4, '0')}`
  } catch (error) {
    console.error('Error generating order number:', error)
  }
}

const addressOptions = computed(() => {
  if (!form.value.buyer_id) return []
  return addressesStore.buyerAddresses.value
    .filter((a) => a.buyer_id === form.value.buyer_id)
    .map((a) => ({
      id: a.id,
      label: `${a.address_line1}, ${a.city}, ${a.state || ''} ${a.postal_code}`,
    }))
})

const priceHint = computed(() => {
  if (!selectedEvent.value) return 'Select an event to calculate price'
  if (form.value.quantity <= 0) return 'Enter quantity to calculate price'
  return `Price: $${selectedEvent.value.price_single} (single) or $${selectedEvent.value.price_multi} each (multi)`
})

function calculatePrice() {
  if (!selectedEvent.value || form.value.quantity <= 0) {
    form.value.total_price = 0
    return
  }
  if (form.value.quantity === 1) {
    form.value.total_price = parseFloat(selectedEvent.value.price_single)
  } else {
    form.value.total_price = parseFloat(selectedEvent.value.price_multi) * form.value.quantity
  }

  // Auto-populate package dimensions based on quantity
  updatePackageDimensions()
}

function updatePackageDimensions() {
  if (form.value.quantity <= 0) {
    form.value.length = null
    form.value.width = null
    form.value.height = null
    form.value.weight = null
    return
  }

  const dimensions = getPackageDimensions(form.value.quantity)
  if (dimensions) {
    form.value.length = dimensions.length
    form.value.width = dimensions.width
    form.value.height = dimensions.height
    form.value.weight = dimensions.weight

    // Trigger postage calculation if zone is available
    calculatePostageCost()
  }
}

function calculatePostageCost() {
  // Need zone and quantity to calculate postage from shipping rates table
  if (!form.value.usps_zone || !form.value.quantity || form.value.quantity <= 0) {
    form.value.estimated_postage_cost = null
    return
  }

  // Find rate from shipping rates table (quantity + zone)
  const rate = shippingRatesStore.findRate(form.value.quantity, form.value.usps_zone)
  form.value.estimated_postage_cost = rate
}

function handleEventSelect() {
  calculatePrice()
}

async function loadBuyers() {
  if (buyersStore.buyers.value.length === 0) {
    await buyersStore.refetch()
  }
}

async function loadEvents() {
  if (eventsStore.events.value.length === 0) {
    await eventsStore.refetch()
  }
}

async function loadAddressesForBuyer() {
  await addressesStore.refetch()
}

async function handleCreateBuyer() {
  if (!newBuyer.value.first_name || !newBuyer.value.last_name) {
    $q.notify({
      type: 'negative',
      message: 'First name and last name are required',
    })
    return
  }

  creatingBuyer.value = true
  try {
    const buyer = await buyersStore.createBuyer({
      first_name: newBuyer.value.first_name.trim(),
      last_name: newBuyer.value.last_name.trim(),
      email: newBuyer.value.email?.trim() || null,
    })
    form.value.buyer_id = buyer.id
    selectedBuyer.value = {
      id: buyer.id,
      label: `${buyer.first_name} ${buyer.last_name}`,
      email: buyer.email,
    }
    showCreateBuyerDialog.value = false
    newBuyer.value = { first_name: '', last_name: '', email: '' }
    await loadAddressesForBuyer()
    $q.notify({
      type: 'positive',
      message: 'Buyer created successfully',
    })
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Error creating buyer: ' + error.message,
    })
  } finally {
    creatingBuyer.value = false
  }
}

// Mapbox address search handlers
async function handleAddressFilter(val, update) {
  if (val.length < 3) {
    update(() => {
      addressSuggestions.value = []
    })
    return
  }

  const suggestions = await searchAddresses(val, { country: newAddress.value.country || 'US' })
  update(() => {
    addressSuggestions.value = suggestions
  })
}

function selectMapboxAddress(address) {
  if (address) {
    newAddress.value.address_line1 = address.addressLine1 || ''
    newAddress.value.address_line2 = address.addressLine2 || ''
    newAddress.value.city = address.city || ''
    newAddress.value.state = address.state || ''
    newAddress.value.postal_code = address.postalCode || ''
    newAddress.value.country = address.country || 'US'
  }
}

async function handleCreateAddress() {
  if (!form.value.buyer_id) {
    $q.notify({
      type: 'negative',
      message: 'Please select a buyer first',
    })
    return
  }

  if (!newAddress.value.address_line1 || !newAddress.value.city || !newAddress.value.postal_code) {
    $q.notify({
      type: 'negative',
      message: 'Address line 1, city, and postal code are required',
    })
    return
  }

  creatingAddress.value = true
  try {
    const address = await addressesStore.createBuyerAddress({
      buyer_id: form.value.buyer_id,
      address_line1: newAddress.value.address_line1.trim(),
      address_line2: newAddress.value.address_line2?.trim() || null,
      city: newAddress.value.city.trim(),
      state: newAddress.value.state?.trim() || null,
      postal_code: newAddress.value.postal_code.trim(),
      country: newAddress.value.country || 'US',
    })
    form.value.address_id = address.id
    showCreateAddressDialog.value = false
    // Reset form and Mapbox state
    newAddress.value = {
      address_line1: '',
      address_line2: '',
      city: '',
      state: '',
      postal_code: '',
      country: 'US',
    }
    selectedMapboxAddress.value = null
    addressSuggestions.value = []
    $q.notify({
      type: 'positive',
      message: 'Address created successfully',
    })
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Error creating address: ' + error.message,
    })
  } finally {
    creatingAddress.value = false
  }
}

async function calculateZoneForAddress() {
  if (!form.value.address_id) {
    form.value.usps_zone = null
    return
  }

  const address = addressesStore.buyerAddresses.value.find((a) => a.id === form.value.address_id)

  if (address && address.postal_code) {
    try {
      const zone = await calculateZone(address.postal_code)
      form.value.usps_zone = zone
      // Calculate postage cost after zone is set
      calculatePostageCost()
    } catch (error) {
      console.error('Error calculating USPS zone:', error)
      // Don't show error to user, just log it
    }
  } else {
    form.value.usps_zone = null
  }
}

watch(
  () => form.value.buyer_id,
  () => {
    // Reset address when buyer changes
    form.value.address_id = null
    form.value.usps_zone = null
  },
)

watch(
  () => form.value.address_id,
  async () => {
    // Calculate zone when address changes
    await calculateZoneForAddress()
    // Calculate postage cost after zone is calculated
    calculatePostageCost()
  },
)

watch(
  () => form.value.quantity,
  () => {
    calculatePrice()
  },
)

watch(
  () => form.value.event_id,
  () => {
    calculatePrice()
    // Auto-generate order number when event is selected
    if (form.value.event_id && isNew.value && !form.value.order_number) {
      generateOrderNumber()
    }
  },
)

onMounted(async () => {
  // Load all data first
  await Promise.all([
    loadBuyers(),
    loadEvents(),
    shippingRatesStore.refetch(),
    ordersStore.refetch(),
  ])
  const id = route.params.id
  if (id && id !== 'new') {
    isNew.value = false
    // Fetch order data
    await ordersStore.refetch()
    const order = ordersStore.orders.value.find((o) => o.id === id)
    if (order) {
      const orderDate = new Date(order.order_date)
      const savedAddressId = order.address_id || null
      // Set buyer_id first
      form.value.buyer_id = order.buyer_id
      const buyer = buyersStore.buyers.value.find((b) => b.id === order.buyer_id)
      if (buyer) {
        selectedBuyer.value = {
          id: buyer.id,
          label: `${buyer.first_name} ${buyer.last_name}`,
          email: buyer.email,
        }
      }
      form.value.event_id = order.event_id
      form.value.order_date = orderDate.toISOString().slice(0, 16)
      form.value.quantity = order.quantity || 1
      // Generate order number if it doesn't exist
      if (!order.order_number && order.event_id) {
        await generateOrderNumber()
        // Save the generated order number
        if (form.value.order_number) {
          await ordersStore.updateOrder(order.id, { order_number: form.value.order_number })
        }
      }
      form.value.total_price = parseFloat(order.total_price) || 0
      form.value.amount_paid = parseFloat(order.amount_paid) || 0
      form.value.fee = parseFloat(order.fee) || 0
      form.value.payment_method = order.payment_method || ''
      form.value.room_number = order.room_number || ''
      form.value.order_number = order.order_number || ''
      form.value.tracking_number = order.tracking_number || ''
      form.value.status = order.status || 'Ordered'
      form.value.usps_zone = order.usps_zone || null
      form.value.length = order.length || null
      form.value.width = order.width || null
      form.value.height = order.height || null
      form.value.weight = order.weight || null
      form.value.estimated_postage_cost = order.estimated_postage_cost || null
      form.value.actual_postage_cost = order.actual_postage_cost || null
      form.value.notes = order.notes || ''
      // Wait for next tick so addressOptions computed property updates
      await nextTick()
      await loadAddressesForBuyer()
      await nextTick()
      form.value.address_id = savedAddressId
      // Calculate zone and postage for existing order
      await calculateZoneForAddress()
    }
  } else {
    // New order: set default event to JC22
    const jc22Event = eventsStore.events.value.find((e) => e.name === 'JC22')
    if (jc22Event) {
      form.value.event_id = jc22Event.id
      // Trigger price calculation after event is set
      await nextTick()
      calculatePrice()
      // Generate order number for new order
      await generateOrderNumber()
    }
    // Set order_date to current EST time (already set in form initialization, but refresh it)
    form.value.order_date = getCurrentESTDateTime()
  }
})

async function handleSave() {
  if (
    !form.value.buyer_id ||
    !form.value.event_id ||
    !form.value.order_date ||
    form.value.quantity <= 0
  ) {
    $q.notify({
      type: 'negative',
      message: 'Please fill in all required fields',
    })
    return
  }

  if (form.value.total_price < 0 || form.value.amount_paid < 0 || form.value.fee < 0) {
    $q.notify({
      type: 'negative',
      message: 'Prices and fee must be >= 0',
    })
    return
  }

  saving.value = true
  try {
    const orderData = {
      buyer_id: form.value.buyer_id,
      address_id: form.value.address_id || null,
      event_id: form.value.event_id,
      order_date: new Date(form.value.order_date).toISOString(),
      quantity: form.value.quantity,
      total_price: form.value.total_price,
      amount_paid: form.value.amount_paid,
      fee: form.value.fee || 0,
      payment_method: form.value.payment_method || null,
      room_number: form.value.room_number || null,
      order_number: form.value.order_number || null,
      tracking_number: form.value.tracking_number || null,
      status: form.value.status || 'Ordered',
      usps_zone: form.value.usps_zone || null,
      length: form.value.length || null,
      width: form.value.width || null,
      height: form.value.height || null,
      weight: form.value.weight || null,
      estimated_postage_cost: form.value.estimated_postage_cost || null,
      actual_postage_cost: form.value.actual_postage_cost || null,
      notes: form.value.notes || null,
    }
    if (isNew.value) {
      await ordersStore.createOrder(orderData)
      $q.notify({
        type: 'positive',
        message: 'Order created successfully',
      })
    } else {
      await ordersStore.updateOrder(route.params.id, orderData)
      $q.notify({
        type: 'positive',
        message: 'Order updated successfully',
      })
    }
    router.push({ name: 'bandanas-orders' })
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Error saving order: ' + error.message,
    })
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.past-order-card {
  transition: box-shadow 0.2s;
}

.past-order-card:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}
</style>
