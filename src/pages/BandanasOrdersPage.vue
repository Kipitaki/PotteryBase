<template>
  <q-page padding class="bg-grey-1 bandanas-page">
    <!-- Local Only Banner -->
    <q-banner
      v-if="isLocal"
      class="bg-warning text-dark q-mb-md"
      icon="warning"
      rounded
    >
      <template v-slot:avatar>
        <q-icon name="warning" color="dark" />
      </template>
      <div class="text-weight-bold">Not Here, Go to the Remote</div>
      <div class="text-caption">Remember: Only enter orders on the remote site now.</div>
    </q-banner>

    <div class="row items-center justify-between q-mb-md">
      <div>
        <div class="text-h5 text-weight-bold">Orders</div>
        <div class="text-caption text-grey-7 q-mt-xs">Manage bandana orders</div>
      </div>
      <div class="row q-gutter-sm items-center">
        <q-select
          v-model="selectedEventFilter"
          :options="eventFilterOptions"
          option-value="id"
          option-label="label"
          emit-value
          map-options
          label="Filter by Event"
          outlined
          dense
          style="min-width: 150px"
          @update:model-value="applyEventFilter"
        />
        <q-select
          v-model="selectedStatusFilter"
          :options="statusFilterOptions"
          option-value="value"
          option-label="label"
          emit-value
          map-options
          label="Filter by Status"
          outlined
          dense
          clearable
          style="min-width: 150px"
        />
        <q-btn
          v-if="selectedOrders.length > 0"
          color="primary"
          icon="file_download"
          :label="`Export for Shipping (${selectedOrders.length})`"
          @click="exportSelectedOrders"
        />
        <q-btn
          v-if="selectedOrders.length > 0"
          color="secondary"
          icon="file_download"
          :label="`Export for Update (${selectedOrders.length})`"
          @click="exportForUpdate"
        />
        <q-btn
          v-if="selectedOrders.length > 0"
          color="purple"
          icon="edit"
          label="Bulk Update Status"
          @click="bulkStatusDialog = true"
        />
        <q-btn
          color="purple"
          icon="upload_file"
          label="Import Tracking"
          @click="trackingImportDialog = true"
        />
        <q-btn color="purple" icon="upload_file" label="Import CSV" @click="csvDialog = true" />
        <!-- <q-btn
          color="negative"
          icon="delete_sweep"
          label="Delete All"
          @click="confirmDeleteAll"
          :disable="!ordersStore.orders.value.length"
        /> -->
        <q-btn
          color="purple"
          icon="add"
          label="Add Order"
          @click="router.push({ name: 'bandanas-order-edit', params: { id: 'new' } })"
        />
      </div>
    </div>

    <div class="row items-center q-mb-md">
      <q-input
        v-model="orderSearchQuery"
        outlined
        dense
        clearable
        label="Search orders"
        placeholder="Search by buyer, email, order #, street, etc."
        prepend-inner-icon="search"
        class="col-12 col-md-5"
      />
    </div>

    <!-- Profit and Loss Statement -->
    <q-card v-if="selectedEventFilter && profitLossData" class="q-mb-md">
      <q-card-section>
        <div class="row q-col-gutter-md">
          <!-- Image on the left side -->
          <div v-if="profitLossData.eventImageUrl" class="col-12 col-md-3">
            <img
              :src="profitLossData.eventImageUrl"
              alt="Bandana Image"
              style="
                width: 100%;
                max-width: 300px;
                height: auto;
                object-fit: cover;
                border-radius: 8px;
              "
            />
          </div>
          <!-- All content on the right side -->
          <div :class="profitLossData.eventImageUrl ? 'col-12 col-md-9' : 'col-12'">
            <!-- Header -->
            <div class="row items-start justify-between q-mb-md">
              <div>
                <div class="text-h6 text-weight-bold">Profit & Loss Statement</div>
                <div class="text-caption text-grey-7 q-mt-xs">
                  {{ profitLossData.eventName }}
                </div>
              </div>
              <div class="text-right">
                <div class="text-caption text-grey-7">Qty Sold</div>
                <div class="text-h3 text-weight-bold text-primary">
                  {{ profitLossData.qtySold }}
                </div>
              </div>
            </div>

            <!-- Financial Data -->
            <div class="row q-col-gutter-md">
              <!-- Event Costs -->
              <div class="col-12 col-md-6">
                <div class="text-subtitle2 text-weight-bold q-mb-sm">Event Costs</div>
                <div class="row q-col-gutter-sm">
                  <div class="col-12">
                    <div class="text-caption text-grey-7">Total Cost</div>
                    <div class="text-body1 text-weight-bold">
                      ${{ formatCurrency(profitLossData.totalCost) }}
                    </div>
                  </div>
                  <div class="col-12">
                    <div class="text-caption text-grey-7">Price per Bandana</div>
                    <div class="text-body1">
                      ${{ formatCurrency(profitLossData.pricePerBandana) }}
                    </div>
                  </div>
                </div>
              </div>

              <!-- Order Statistics -->
              <div class="col-12 col-md-6">
                <div class="text-subtitle2 text-weight-bold q-mb-sm">Order Statistics</div>
                <div class="row q-col-gutter-sm">
                  <div class="col-12">
                    <div class="text-caption text-grey-7">Total Paid</div>
                    <div class="text-body1 text-weight-bold">
                      ${{ formatCurrency(profitLossData.totalPaid) }}
                    </div>
                  </div>
                  <div class="col-12">
                    <div class="text-caption text-grey-7">Total Shipping Charges</div>
                    <div class="text-body1 text-weight-bold">
                      ${{ formatCurrency(profitLossData.totalShippingCharges) }}
                    </div>
                    <div class="text-caption text-grey-6">
                      (uses actual if available, otherwise estimated)
                    </div>
                  </div>
                  <div class="col-12">
                    <div class="text-caption text-grey-7">Avg Profit / Bandana (sold)</div>
                    <div class="text-body1">
                      ${{ formatCurrency(profitLossData.averageProfitPerBandanaSold) }}
                    </div>
                  </div>
                </div>
              </div>

              <!-- Profit/Loss Summary -->
              <div class="col-12">
                <q-separator class="q-my-md" />
                <div class="row items-center justify-between">
                  <div class="text-subtitle1 text-weight-bold">Net Profit/Loss</div>
                  <div
                    :class="[
                      'text-h6',
                      'text-weight-bold',
                      profitLossData.netProfitLoss >= 0 ? 'text-positive' : 'text-negative',
                    ]"
                  >
                    ${{ formatCurrency(profitLossData.netProfitLoss) }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </q-card-section>
    </q-card>

    <q-table
      :rows="searchFilteredOrders"
      :columns="columns"
      row-key="id"
      :loading="ordersStore.loading.value"
      flat
      bordered
      :rows-per-page-options="[100]"
      :pagination="{ rowsPerPage: 100 }"
      v-model:selected="selectedOrders"
      selection="multiple"
    >
      <template v-slot:body-cell-buyer="props">
        <q-td :props="props">
          <q-btn
            flat
            dense
            no-caps
            :label="
              `${props.row.buyer?.first_name || ''} ${props.row.buyer?.last_name || ''}`.trim() ||
              'Unknown Buyer'
            "
            color="primary"
            @click="
              router.push({ name: 'bandanas-buyer-detail', params: { id: props.row.buyer_id } })
            "
            class="text-weight-medium"
          />
          <div class="text-caption text-grey-7">{{ props.row.buyer?.email }}</div>
        </q-td>
      </template>
      <template v-slot:body-cell-event="props">
        <q-td :props="props"> {{ props.row.event?.name }} ({{ props.row.event?.year }}) </q-td>
      </template>
      <template v-slot:body-cell-address="props">
        <q-td :props="props">
          <div v-if="props.row.buyer_address">
            <div>{{ props.row.buyer_address.address_line1 }}</div>
            <div v-if="props.row.buyer_address.address_line2">
              {{ props.row.buyer_address.address_line2 }}
            </div>
            <div>
              {{ props.row.buyer_address.city
              }}{{ props.row.buyer_address.state ? ', ' + props.row.buyer_address.state : '' }}
              {{ props.row.buyer_address.postal_code }}
            </div>
          </div>
          <span v-else class="text-grey-6">No address</span>
        </q-td>
      </template>
      <template v-slot:body-cell-amounts="props">
        <q-td :props="props">
          <div>Qty: {{ props.row.quantity }}</div>
          <div>Total: ${{ props.row.total_price }}</div>
          <div>Paid: ${{ props.row.amount_paid }}</div>
        </q-td>
      </template>
      <template v-slot:body-cell-estimated_postage_cost="props">
        <q-td :props="props">
          <div :class="[props.row.actual_postage_cost ? 'text-dark' : 'text-grey-6']">
            {{ getPostageDisplay(props.row) }}
          </div>
        </q-td>
      </template>
      <template v-slot:body-cell-profit_per_bandana="props">
        <q-td :props="props">
          <div
            :class="[
              'text-weight-medium',
              calculateProfitPerBandana(props.row) >= 0 ? 'text-positive' : 'text-negative',
            ]"
          >
            ${{ formatCurrency(calculateProfitPerBandana(props.row)) }}
          </div>
        </q-td>
      </template>
      <template v-slot:body-cell-status="props">
        <q-td :props="props">
          <q-chip :color="getStatusColor(props.row.status)" text-color="white" size="sm">
            {{ props.row.status || 'Ordered' }}
          </q-chip>
        </q-td>
      </template>
      <template v-slot:body-cell-actions="props">
        <q-td :props="props">
          <q-btn
            flat
            dense
            round
            icon="edit"
            color="purple"
            @click="router.push({ name: 'bandanas-order-edit', params: { id: props.row.id } })"
          />
          <q-btn
            flat
            dense
            round
            icon="delete"
            color="negative"
            @click="confirmDelete(props.row)"
          />
        </q-td>
      </template>
    </q-table>
  </q-page>

  <!-- Bulk Status Update Dialog -->
  <q-dialog v-model="bulkStatusDialog" persistent>
    <q-card style="min-width: 400px">
      <q-card-section>
        <div class="text-h6">Bulk Update Status</div>
        <div class="text-caption text-grey-7 q-mt-xs">
          Update status for {{ selectedOrders.length }} selected order(s)
        </div>
      </q-card-section>
      <q-card-section>
        <q-select
          v-model="newBulkStatus"
          :options="statusFilterOptions.filter((s) => s.value !== null)"
          option-value="value"
          option-label="label"
          emit-value
          map-options
          label="New Status *"
          outlined
        />
      </q-card-section>
      <q-card-actions align="right">
        <q-btn flat label="Cancel" @click="bulkStatusDialog = false" />
        <q-btn color="purple" label="Update" @click="updateBulkStatus(newBulkStatus)" />
      </q-card-actions>
    </q-card>
  </q-dialog>

  <!-- Tracking Import Dialog -->
  <q-dialog v-model="trackingImportDialog" persistent>
    <q-card style="min-width: 600px; max-width: 800px">
      <q-card-section>
        <div class="text-h6">Import Tracking Numbers</div>
        <div class="text-caption text-grey-7 q-mt-xs">
          Upload a CSV file with Order Number, Tracking Number, and optionally Actual Shipping Cost columns. 
          Orders will be updated to "Tracking Created" status and actual shipping cost if provided.
        </div>
      </q-card-section>
      <q-card-section>
        <q-file
          v-model="trackingFile"
          label="Choose CSV file"
          accept=".csv,text/csv"
          outlined
          :loading="trackingImporting"
        />
        <div v-if="trackingImportResults" class="q-mt-md">
          <q-banner
            :class="trackingImportResults.failed > 0 ? 'bg-warning' : 'bg-positive'"
            rounded
          >
            <template v-slot:avatar>
              <q-icon
                :name="trackingImportResults.failed > 0 ? 'warning' : 'check_circle'"
                :color="trackingImportResults.failed > 0 ? 'warning' : 'positive'"
              />
            </template>
            <div>
              Import complete: {{ trackingImportResults.success }} succeeded,
              {{ trackingImportResults.failed }} failed
            </div>
            <div v-if="trackingImportResults.errors.length" class="q-mt-sm">
              <div
                v-for="(err, idx) in trackingImportResults.errors.slice(0, 5)"
                :key="idx"
                class="text-caption"
              >
                Row {{ err.row }}: {{ err.error }}
              </div>
              <div v-if="trackingImportResults.errors.length > 5" class="text-caption q-mt-xs">
                ... and {{ trackingImportResults.errors.length - 5 }} more errors
              </div>
            </div>
          </q-banner>
        </div>
      </q-card-section>
      <q-card-actions align="right">
        <q-btn flat label="Close" @click="closeTrackingDialog" />
        <q-btn
          color="purple"
          label="Import"
          :loading="trackingImporting"
          :disable="!trackingFile"
          @click="handleTrackingImport"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>

  <!-- Import CSV Dialog -->
  <q-dialog v-model="csvDialog" persistent>
    <q-card style="min-width: 600px; max-width: 800px">
      <q-card-section>
        <div class="text-h6">Import Orders from CSV</div>
        <div class="text-caption text-grey-7 q-mt-xs">
          Upload a file or paste CSV data with buyer and order information. The CSV should include:
          Date, First Name, Last Name, Address, City, State, Zip, QTY, Net, Fee, Shipping, Tracking.
        </div>
      </q-card-section>

      <q-card-section>
        <q-select
          v-model="importEventId"
          :options="eventFilterOptions.filter((e) => e.id !== null)"
          option-value="id"
          option-label="label"
          emit-value
          map-options
          label="Event *"
          outlined
          :disable="csvImporting"
          hint="Select the event these orders belong to (e.g., JC18)"
        />
      </q-card-section>

      <q-card-section>
        <q-tabs v-model="importTab" class="text-grey" active-color="purple">
          <q-tab name="file" label="Upload File" icon="attach_file" />
          <q-tab name="csv" label="Paste CSV" icon="content_paste" />
        </q-tabs>

        <q-separator />

        <q-tab-panels v-model="importTab" animated>
          <q-tab-panel name="file">
            <q-file
              v-model="csvFile"
              label="Choose CSV file"
              accept=".csv,text/csv"
              outlined
              :disable="csvImporting"
              @update:model-value="handleFileUpload"
            >
              <template v-slot:prepend>
                <q-icon name="attach_file" />
              </template>
            </q-file>
          </q-tab-panel>

          <q-tab-panel name="csv">
            <div class="text-subtitle2 q-mb-sm">Paste CSV data:</div>
            <q-input
              v-model="pastedData"
              type="textarea"
              outlined
              rows="10"
              placeholder="Event,Quantity,Total Paid,Amount Paid,BuyerId,AddressId,How Paid,Notes&#10;JC19,2,23.00,23.00,a1HgL0000002ckL,a1GgL00003GuTYL,Venmo,"
              :disable="csvImporting"
              @update:model-value="parsePastedData"
            />
          </q-tab-panel>
        </q-tab-panels>

        <div v-if="csvPreview.length" class="q-mt-md">
          <div class="text-subtitle2 q-mb-sm">Preview ({{ csvPreview.length }} rows)</div>
          <q-table
            :rows="csvPreview.slice(0, 10)"
            :columns="csvColumns"
            row-key="__index"
            flat
            bordered
            dense
            :rows-per-page-options="[0]"
            hide-pagination
          />
          <div v-if="csvPreview.length > 10" class="text-caption text-grey-7 q-mt-xs">
            ... and {{ csvPreview.length - 10 }} more rows
          </div>
        </div>

        <div v-if="csvImportResults" class="q-mt-md">
          <q-banner :class="csvImportResults.failed > 0 ? 'bg-warning' : 'bg-positive'" rounded>
            <template v-slot:avatar>
              <q-icon
                :name="csvImportResults.failed > 0 ? 'warning' : 'check_circle'"
                :color="csvImportResults.failed > 0 ? 'warning' : 'positive'"
              />
            </template>
            <div>
              Import complete: {{ csvImportResults.success }} succeeded,
              {{ csvImportResults.failed }} failed
            </div>
            <div v-if="csvImportResults.errors.length" class="q-mt-sm">
              <div
                v-for="(err, idx) in csvImportResults.errors.slice(0, 5)"
                :key="idx"
                class="text-caption"
              >
                Row {{ err.row }}: {{ err.error }}
              </div>
              <div v-if="csvImportResults.errors.length > 5" class="text-caption">
                ... and {{ csvImportResults.errors.length - 5 }} more errors
              </div>
            </div>
          </q-banner>
        </div>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn flat label="Cancel" color="purple" :disable="csvImporting" @click="closeCsvDialog" />
        <q-btn
          flat
          label="Import"
          color="purple"
          :loading="csvImporting"
          :disable="!csvPreview.length || !importEventId || csvImporting"
          @click="importCSV"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>

  <q-dialog v-model="showDeleteConfirm" persistent>
    <q-card>
      <q-card-section>
        <div class="text-h6">Delete Order</div>
      </q-card-section>
      <q-card-section> Are you sure you want to delete this order? </q-card-section>
      <q-card-actions align="right">
        <q-btn flat label="Cancel" color="purple" v-close-popup />
        <q-btn flat label="Delete" color="negative" :loading="deleting" @click="handleDelete" />
      </q-card-actions>
    </q-card>
  </q-dialog>

  <q-dialog v-model="showDeleteAllConfirm" persistent>
    <q-card>
      <q-card-section>
        <div class="text-h6">Delete All Orders</div>
      </q-card-section>
      <q-card-section>
        Are you sure you want to delete all {{ ordersStore.orders.value.length }} orders? This
        action cannot be undone.
      </q-card-section>
      <q-card-actions align="right">
        <q-btn flat label="Cancel" color="purple" v-close-popup />
        <q-btn
          flat
          label="Delete All"
          color="negative"
          :loading="deletingAll"
          @click="handleDeleteAll"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useOrdersStore } from 'src/stores/bandanas/orders'
import { useBuyersStore } from 'src/stores/bandanas/buyers'
import { useBuyerAddressesStore } from 'src/stores/bandanas/buyerAddresses'
import { useEventsStore } from 'src/stores/bandanas/events'
import { useQuasar } from 'quasar'

const router = useRouter()
const $q = useQuasar()
const ordersStore = useOrdersStore()
const buyersStore = useBuyersStore()
const addressesStore = useBuyerAddressesStore()
const eventsStore = useEventsStore()

// Check if running locally
const isLocal =
  process.env.NODE_ENV === 'development' && window.location.hostname === 'localhost'

const showDeleteConfirm = ref(false)
const orderToDelete = ref(null)
const deleting = ref(false)
const showDeleteAllConfirm = ref(false)
const deletingAll = ref(false)
const selectedEventFilter = ref(null)

// Event filter options
const eventFilterOptions = computed(() => {
  const options = [
    { id: null, label: 'All Events' },
    ...eventsStore.events.value.map((e) => ({
      id: e.id,
      label: `${e.name} (${e.year})`,
    })),
  ]
  return options
})

// Status filter options
const statusFilterOptions = [
  { value: null, label: 'All Statuses' },
  { value: 'Ordered', label: 'Ordered' },
  { value: 'Pending Shipping', label: 'Pending Shipping' },
  { value: 'Tracking Created', label: 'Tracking Created' },
  { value: 'Shipped', label: 'Shipped' },
  { value: 'Received', label: 'Received' },
  { value: 'Other', label: 'Other' },
]

const selectedStatusFilter = ref(null)
const selectedOrders = ref([])
const bulkStatusDialog = ref(false)
const trackingImportDialog = ref(false)
const newBulkStatus = ref('Shipped')
const orderSearchQuery = ref('')

// Filtered orders based on selected event
const filteredOrders = computed(() => {
  if (!selectedEventFilter.value) {
    return ordersStore.orders.value
  }
  return ordersStore.orders.value.filter((order) => order.event_id === selectedEventFilter.value)
})

// Filtered orders by status
const filteredOrdersByStatus = computed(() => {
  if (!selectedStatusFilter.value) {
    return filteredOrders.value
  }
  return filteredOrders.value.filter((order) => order.status === selectedStatusFilter.value)
})

const searchFilteredOrders = computed(() => {
  const query = orderSearchQuery.value.trim().toLowerCase()
  if (!query) {
    return filteredOrdersByStatus.value
  }
  return filteredOrdersByStatus.value.filter((order) => orderMatchesSearch(order, query))
})

// Profit and Loss data
const profitLossData = computed(() => {
  if (!selectedEventFilter.value) {
    return null
  }

  // Get the selected event
  const event = eventsStore.events.value.find((e) => e.id === selectedEventFilter.value)
  if (!event) return null

  // Calculate event costs
  const cost = parseFloat(event.bandana_cost) || 0
  const freight = parseFloat(event.freight) || 0
  const fees = parseFloat(event.fee_tax_transaction_fees) || 0
  const totalCost = cost + freight + fees
  const totalQty = event.total_qty || 1 // Avoid division by zero
  const pricePerBandana = totalCost / totalQty

  // Calculate order statistics
  const qtySold = filteredOrders.value.reduce((sum, order) => sum + (order.quantity || 0), 0)
  const totalPaid = filteredOrders.value.reduce(
    (sum, order) => sum + (parseFloat(order.amount_paid) || 0),
    0,
  )

  // Calculate total shipping charges (use actual if available, otherwise estimated)
  const totalShippingCharges = filteredOrders.value.reduce((sum, order) => {
    const actual = parseFloat(order.actual_postage_cost)
    const estimated = parseFloat(order.estimated_postage_cost)
    // Use actual if it exists and is valid, otherwise use estimated
    const shippingCost =
      actual && !isNaN(actual) ? actual : estimated && !isNaN(estimated) ? estimated : 0
    return sum + shippingCost
  }, 0)

  // Calculate net profit/loss (subtract shipping charges and freight_out from the profit)
  const freightOut = parseFloat(event.freight_out) || 0
  const netProfitLoss = totalPaid - totalCost - totalShippingCharges - freightOut

  const costForSold = pricePerBandana * qtySold
  const profitOnSold = totalPaid - costForSold - totalShippingCharges - freightOut

  return {
    eventName: `${event.name} (${event.year})`,
    eventImageUrl: event.image_url || null,
    cost,
    freight,
    fees,
    totalCost,
    pricePerBandana,
    qtySold,
    totalPaid,
    averageProfitPerBandanaSold: qtySold > 0 ? profitOnSold / qtySold : 0,
    totalShippingCharges,
    netProfitLoss,
  }
})

// Format currency helper
function formatCurrency(value) {
  if (value === null || value === undefined || isNaN(value)) {
    return '0.00'
  }
  return Number(value).toFixed(2)
}

// Get postage display (actual if available, otherwise estimated)
function getPostageDisplay(order) {
  const actual = parseFloat(order.actual_postage_cost)
  const estimated = parseFloat(order.estimated_postage_cost)

  if (actual && !isNaN(actual)) {
    return `$${actual.toFixed(2)}`
  } else if (estimated && !isNaN(estimated)) {
    return `$${estimated.toFixed(2)}`
  }
  return '-'
}

function orderMatchesSearch(order, query) {
  if (!order || !query) {
    return false
  }

  const searchFields = [
    order.order_number,
    `${order.buyer?.first_name || ''} ${order.buyer?.last_name || ''}`.trim(),
    order.buyer?.email,
    order.event?.name,
    order.event?.year,
    order.status,
    order.tracking_number,
    order.buyer_address?.address_line1,
    order.buyer_address?.address_line2,
    order.buyer_address?.city,
    order.buyer_address?.state,
    order.buyer_address?.postal_code,
  ]

  return searchFields.some((field) => (field || '').toString().toLowerCase().includes(query))
}

// Calculate profit per bandana for an order
function calculateProfitPerBandana(order) {
  if (!order || !order.event_id || !order.quantity || order.quantity <= 0) {
    return 0
  }

  // Get the event to calculate cost per bandana
  const event = eventsStore.events.value.find((e) => e.id === order.event_id)
  if (!event) return 0

  // Calculate cost per bandana from event
  const eventCost = parseFloat(event.bandana_cost) || 0
  const eventFreight = parseFloat(event.freight) || 0
  const eventFees = parseFloat(event.fee_tax_transaction_fees) || 0
  const totalEventCost = eventCost + eventFreight + eventFees
  const totalQty = event.total_qty || 1 // Avoid division by zero
  const costPerBandana = totalEventCost / totalQty

  // Get shipping cost (use actual if available, otherwise estimated)
  const actualShipping = parseFloat(order.actual_postage_cost)
  const estimatedShipping = parseFloat(order.estimated_postage_cost)
  const shippingCost =
    actualShipping && !isNaN(actualShipping)
      ? actualShipping
      : estimatedShipping && !isNaN(estimatedShipping)
        ? estimatedShipping
        : 0

  // Calculate total cost for this order
  const totalOrderCost = costPerBandana * order.quantity + shippingCost

  // Calculate net profit
  const amountPaid = parseFloat(order.amount_paid) || 0
  const netProfit = amountPaid - totalOrderCost

  // Calculate profit per bandana
  return netProfit / order.quantity
}

// Set default to JC22 on mount and backfill order numbers
onMounted(async () => {
  await eventsStore.refetch()
  await ordersStore.refetch()

  // Backfill order numbers for existing orders
  await backfillOrderNumbers()

  const jc22Event = eventsStore.events.value.find((e) => e.name === 'JC22')
  if (jc22Event) {
    selectedEventFilter.value = jc22Event.id
  } else {
    // If JC22 not found, default to most recent event
    if (eventsStore.events.value.length > 0) {
      selectedEventFilter.value = eventsStore.events.value[0].id
    }
  }
})

// Backfill order numbers for existing orders that don't have them
// Numbers increment globally across all events, but grouped by event
// All JC19 orders first (0001-0118), then all JC20 orders (0119-0279), etc.
async function backfillOrderNumbers() {
  const ordersWithoutNumbers = ordersStore.orders.value.filter((o) => !o.order_number && o.event_id)

  if (ordersWithoutNumbers.length === 0) return

  try {
    // Get all existing order numbers to find the highest global number
    const allOrders = ordersStore.orders.value
    const existingNumbers = allOrders
      .map((o) => o.order_number)
      .filter((num) => num && num.match(/^[A-Z0-9]+-\d+$/)) // Match any EventName-#### pattern
      .map((num) => {
        const match = num.match(/-(\d+)$/)
        return match ? parseInt(match[1], 10) : 0
      })

    // Find the highest number globally - this is our starting point
    let nextNumber = existingNumbers.length > 0 ? Math.max(...existingNumbers) + 1 : 1

    // Group orders by event
    const ordersByEvent = {}
    for (const order of ordersWithoutNumbers) {
      const event = eventsStore.events.value.find((e) => e.id === order.event_id)
      if (event) {
        if (!ordersByEvent[event.name]) {
          ordersByEvent[event.name] = []
        }
        ordersByEvent[event.name].push(order)
      }
    }

    // Sort events by name to process in order (JC19, then JC20, etc.)
    const eventNames = Object.keys(ordersByEvent).sort()

    // Assign order numbers grouped by event
    // All orders for first event (JC19), then all orders for second event (JC20), etc.
    for (const eventName of eventNames) {
      const orders = ordersByEvent[eventName]
      // Sort orders by date to maintain chronological order within each event
      orders.sort((a, b) => new Date(a.order_date) - new Date(b.order_date))

      // Assign numbers to all orders in this event, continuing from previous event
      for (const order of orders) {
        const orderNumber = `${eventName}-${String(nextNumber).padStart(4, '0')}`
        await ordersStore.updateOrder(order.id, { order_number: orderNumber })
        nextNumber++
      }
    }

    // Refresh orders after backfilling
    await ordersStore.refetch()
  } catch (error) {
    console.error('Error backfilling order numbers:', error)
  }
}

function applyEventFilter() {
  // Filter is applied via computed property
}

// CSV Import
const csvDialog = ref(false)
const importTab = ref('file')
const csvFile = ref(null)
const pastedData = ref('')
const csvPreview = ref([])
const csvImporting = ref(false)
const csvImportResults = ref(null)
const importEventId = ref(null)

const csvColumns = [
  {
    name: 'date',
    label: 'Date',
    field: 'date',
    align: 'left',
  },
  {
    name: 'first_name',
    label: 'First Name',
    field: 'first_name',
    align: 'left',
  },
  {
    name: 'last_name',
    label: 'Last Name',
    field: 'last_name',
    align: 'left',
  },
  {
    name: 'net',
    label: 'Net',
    field: 'net',
    align: 'left',
  },
  {
    name: 'qty',
    label: 'QTY',
    field: 'qty',
    align: 'left',
  },
  {
    name: 'address_line_1',
    label: 'Address Line 1',
    field: 'address_line_1',
    align: 'left',
  },
  {
    name: 'city',
    label: 'City',
    field: 'city',
    align: 'left',
  },
  {
    name: 'state',
    label: 'State',
    field: 'state',
    align: 'left',
  },
  {
    name: 'zip',
    label: 'Zip',
    field: 'zip',
    align: 'left',
  },
]

const columns = [
  {
    name: 'selection',
    label: '',
    field: 'selection',
    align: 'center',
    style: 'width: 50px',
  },
  {
    name: 'order_number',
    label: 'Order #',
    field: 'order_number',
    align: 'left',
    sortable: true,
  },
  {
    name: 'order_date',
    label: 'Date',
    field: 'order_date',
    align: 'left',
    sortable: true,
    format: (val) => new Date(val).toLocaleDateString(),
  },
  {
    name: 'buyer',
    label: 'Buyer',
    field: 'buyer',
    align: 'left',
  },
  {
    name: 'event',
    label: 'Event',
    field: 'event',
    align: 'left',
  },
  {
    name: 'address',
    label: 'Shipping Address',
    field: 'address',
    align: 'left',
  },
  {
    name: 'amounts',
    label: 'Amounts',
    field: 'amounts',
    align: 'left',
  },
  {
    name: 'payment_method',
    label: 'Payment',
    field: 'payment_method',
    align: 'left',
  },
  {
    name: 'status',
    label: 'Status',
    field: 'status',
    align: 'left',
    sortable: true,
  },
  {
    name: 'quantity',
    label: 'Qty',
    field: 'quantity',
    align: 'center',
    sortable: true,
  },
  {
    name: 'estimated_postage_cost',
    label: 'Postage',
    field: 'estimated_postage_cost',
    align: 'right',
    sortable: true,
    format: (val) => (val ? `$${parseFloat(val).toFixed(2)}` : '-'),
  },
  {
    name: 'profit_per_bandana',
    label: 'Profit/Bandana',
    field: 'profit_per_bandana',
    align: 'right',
    sortable: false,
  },
  {
    name: 'actions',
    label: 'Actions',
    field: 'actions',
    align: 'center',
  },
]

function getStatusColor(status) {
  switch (status) {
    case 'Ordered':
      return 'orange'
    case 'Pending Shipping':
      return 'amber'
    case 'Tracking Created':
      return 'cyan'
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

function confirmDelete(order) {
  orderToDelete.value = order
  showDeleteConfirm.value = true
}

// function confirmDeleteAll() {
//   showDeleteAllConfirm.value = true
// }

async function handleDelete() {
  if (!orderToDelete.value) return
  deleting.value = true
  try {
    await ordersStore.deleteOrder(orderToDelete.value.id)
    $q.notify({
      type: 'positive',
      message: 'Order deleted successfully',
    })
    showDeleteConfirm.value = false
    orderToDelete.value = null
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Error deleting order: ' + error.message,
    })
  } finally {
    deleting.value = false
  }
}

// async function handleDeleteAll() {
//   deletingAll.value = true
//   try {
//     await ordersStore.deleteAllOrders()
//     $q.notify({
//       type: 'positive',
//       message: 'All orders deleted successfully',
//     })
//     showDeleteAllConfirm.value = false
//   } catch (error) {
//     $q.notify({
//       type: 'negative',
//       message: 'Error deleting orders: ' + error.message,
//     })
//   } finally {
//     deletingAll.value = false
//   }
// }

// CSV Parsing Functions
function parseCSVLine(line) {
  const result = []
  let current = ''
  let inQuotes = false

  for (let i = 0; i < line.length; i++) {
    const char = line[i]
    if (char === '"') {
      inQuotes = !inQuotes
    } else if (char === ',' && !inQuotes) {
      result.push(current.trim())
      current = ''
    } else {
      current += char
    }
  }
  result.push(current.trim())
  return result
}

function parseCSVText(text) {
  const lines = text.split('\n').filter((line) => line.trim())
  if (lines.length === 0) {
    return []
  }

  // Parse header and normalize column names (handle spaces, underscores, case)
  const rawHeaders = parseCSVLine(lines[0])
  const headers = rawHeaders.map((h) => {
    // Normalize: remove quotes, lowercase, replace spaces with underscores
    return h.replace(/^"|"$/g, '').toLowerCase().trim().replace(/\s+/g, '_').replace(/\//g, '_')
  })

  // Parse rows
  const rows = []
  for (let i = 1; i < lines.length; i++) {
    const values = parseCSVLine(lines[i])
    if (values.length === 0 || values.every((v) => !v || !v.trim())) continue // Skip empty rows

    const row = { __index: i - 1 }
    headers.forEach((header, idx) => {
      // Remove quotes from values
      const value = values[idx] || ''
      row[header] = value.replace(/^"|"$/g, '').trim()
    })

    // Normalize field names for JC18 format and export format
    row.date = row.date || ''
    row.time = row.time || ''
    row.first_name = row.first_name || ''
    row.last_name = row.last_name || ''
    row.email = row.email || ''
    row.gross = row.gross || ''
    row.fee = row.fee || ''
    // Handle both "Net" and "Amount Paid" columns
    row.net = row.net || row.amount_paid || ''
    row.amount_paid = row.amount_paid || row.net || ''
    row.qty = row.qty || row.quantity || ''
    row.address_line_1 = row.address_line || row.address_line_1 || ''
    row.address_line_2 = row.address_line_2 || ''
    row.town_city = row.town_city || row.city || ''
    row.state = row.state || ''
    row.zip = row.zip || ''
    row.shipping = row.shipping || ''
    row.tracking = row.tracking || ''

    rows.push(row)
  }

  return rows
}

async function handleFileUpload() {
  if (!csvFile.value) {
    csvPreview.value = []
    csvImportResults.value = null
    return
  }

  try {
    const text = await csvFile.value.text()
    csvPreview.value = parseCSVText(text)
    csvImportResults.value = null
  } catch (error) {
    console.error('File parsing error:', error)
    csvPreview.value = []
    csvImportResults.value = {
      success: 0,
      failed: 0,
      errors: [{ row: 'N/A', error: error.message || 'Failed to parse file' }],
    }
  }
}

async function parsePastedData() {
  if (!pastedData.value.trim()) {
    csvPreview.value = []
    csvImportResults.value = null
    return
  }

  try {
    csvPreview.value = parseCSVText(pastedData.value)
    csvImportResults.value = null
  } catch (error) {
    console.error('Parsing error:', error)
    csvPreview.value = []
    csvImportResults.value = {
      success: 0,
      failed: 0,
      errors: [{ row: 'N/A', error: error.message || 'Failed to parse data' }],
    }
  }
}

async function importCSV() {
  if (!csvPreview.value.length) return

  if (!importEventId.value) {
    $q.notify({
      type: 'warning',
      message: 'Please select an event before importing',
    })
    return
  }

  csvImporting.value = true
  csvImportResults.value = null

  try {
    const results = {
      success: 0,
      failed: 0,
      errors: [],
    }

    // Get the selected event
    const selectedEvent = eventsStore.events.value.find((e) => e.id === importEventId.value)
    if (!selectedEvent) {
      results.failed++
      results.errors.push({
        row: 'N/A',
        error: 'Selected event not found. Please select a valid event.',
      })
      csvImportResults.value = results
      csvImporting.value = false
      return
    }

    // Refetch buyers and addresses to ensure we have the latest data
    await buyersStore.refetch()
    await addressesStore.refetch()

    for (const row of csvPreview.value) {
      try {
        // Extract data from row
        const firstName = (row.first_name || '').trim()
        const lastName = (row.last_name || '').trim()
        const quantity = parseInt(row.qty || '0', 10)
        // Use amount_paid if available, otherwise fall back to net
        const amountPaid = parseFloat(row.amount_paid || row.net || '0')
        const net = parseFloat(row.net || row.amount_paid || '0')
        const fee = parseFloat(row.fee || '0')
        const shipping = parseFloat(row.shipping || '0')
        const tracking = (row.tracking || '').trim() || null

        // Parse date (format: MM/DD/YY)
        const dateParts = (row.date || '').split('/')
        let orderDate = new Date()
        if (dateParts.length === 3) {
          const month = parseInt(dateParts[0], 10) - 1
          const day = parseInt(dateParts[1], 10)
          let year = parseInt(dateParts[2], 10)
          // Convert 2-digit year to 4-digit (19 -> 2019)
          if (year < 100) {
            year += 2000
          }
          orderDate = new Date(year, month, day)
        }

        // Address fields
        const addressLine1 = (row.address_line_1 || '').trim()
        const addressLine2 = (row.address_line_2 || '').trim() || null
        const city = (row.town_city || '').trim()
        const state = (row.state || '').trim()
        const zip = (row.zip || '').trim()

        // Validation
        if (!firstName || !lastName) {
          results.failed++
          results.errors.push({
            row: row.__index + 1,
            error: 'First Name and Last Name are required',
          })
          continue
        }

        if (!quantity || quantity <= 0) {
          results.failed++
          results.errors.push({
            row: row.__index + 1,
            error: 'Quantity must be greater than 0',
          })
          continue
        }

        if (isNaN(net) || net < 0) {
          results.failed++
          results.errors.push({
            row: row.__index + 1,
            error: 'Net must be a valid number >= 0',
          })
          continue
        }

        // Find or create buyer (match by first name and last name only)
        const email = (row.email || '').trim() || null
        let buyer = buyersStore.buyers.value.find(
          (b) =>
            b.first_name.toLowerCase() === firstName.toLowerCase() &&
            b.last_name.toLowerCase() === lastName.toLowerCase(),
        )

        if (!buyer) {
          // Create new buyer
          buyer = await buyersStore.createBuyer({
            first_name: firstName,
            last_name: lastName,
            email: email,
          })
          if (!buyer) {
            throw new Error('Failed to create buyer')
          }
          // Refetch to get the new buyer in the list
          await buyersStore.refetch()
        }

        // Find or create address (if address info provided)
        let addressUUID = null
        if (addressLine1 && city && state && zip) {
          // Check if address already exists for this buyer (match by address_line1, city, state, zip)
          let address = addressesStore.buyerAddresses.value.find(
            (a) =>
              a.buyer_id === buyer.id &&
              a.address_line1.toLowerCase().trim() === addressLine1.toLowerCase().trim() &&
              a.city.toLowerCase().trim() === city.toLowerCase().trim() &&
              (a.state || '').toLowerCase().trim() === state.toLowerCase().trim() &&
              (a.postal_code || '').trim() === zip.trim(),
          )

          if (!address) {
            // Create new address
            address = await addressesStore.createBuyerAddress({
              buyer_id: buyer.id,
              address_line1: addressLine1,
              address_line2: addressLine2,
              city: city,
              state: state,
              postal_code: zip,
              country: 'US',
            })
            if (!address) {
              throw new Error('Failed to create address')
            }
            // Refetch to get the new address in the list
            await addressesStore.refetch()
          }

          addressUUID = address.id
        }

        // Check if order already exists (match by event + buyer)
        const existingOrder = ordersStore.orders.value.find(
          (o) => o.event_id === selectedEvent.id && o.buyer_id === buyer.id,
        )

        if (existingOrder) {
          // Update existing order - use amount_paid if provided, otherwise keep existing
          const updateData = {
            address_id: addressUUID || existingOrder.address_id,
            order_date: orderDate.toISOString(),
            quantity: quantity || existingOrder.quantity,
            total_price: net || existingOrder.total_price,
            amount_paid: amountPaid > 0 ? amountPaid : existingOrder.amount_paid,
            fee: fee ? Math.abs(fee) : existingOrder.fee,
            actual_postage_cost: shipping > 0 ? shipping : existingOrder.actual_postage_cost,
            tracking_number: tracking || existingOrder.tracking_number,
            status: tracking ? 'Shipped' : existingOrder.status,
          }
          await ordersStore.updateOrder(existingOrder.id, updateData)
        } else {
          // Create new order
          await ordersStore.createOrder({
            buyer_id: buyer.id,
            address_id: addressUUID,
            event_id: selectedEvent.id,
            order_date: orderDate.toISOString(),
            quantity,
            total_price: net,
            amount_paid: amountPaid > 0 ? amountPaid : net,
            fee: Math.abs(fee), // Convert negative fee to positive
            actual_postage_cost: shipping > 0 ? shipping : null,
            tracking_number: tracking,
            status: tracking ? 'Shipped' : 'Ordered',
          })
        }

        results.success++
      } catch (error) {
        results.failed++
        results.errors.push({
          row: row.__index + 1,
          error: error.message || 'Failed to create order',
        })
      }
    }

    csvImportResults.value = results

    if (results.success > 0) {
      $q.notify({
        type: 'positive',
        message: `Successfully imported ${results.success} order(s)`,
      })
      // Refresh the orders list
      await ordersStore.refetch()
    }
  } catch (error) {
    console.error('CSV import error:', error)
    csvImportResults.value = {
      success: 0,
      failed: csvPreview.value.length,
      errors: [{ row: 'N/A', error: error instanceof Error ? error.message : 'Import failed' }],
    }
  } finally {
    csvImporting.value = false
  }
}

function closeCsvDialog() {
  csvDialog.value = false
  csvFile.value = null
  pastedData.value = ''
  csvPreview.value = []
  csvImportResults.value = null
  importTab.value = 'file'
  importEventId.value = null
}

// Export for update (includes all fields for re-importing)
function exportForUpdate() {
  if (selectedOrders.value.length === 0) {
    $q.notify({
      type: 'warning',
      message: 'Please select orders to export',
    })
    return
  }

  // Generate CSV content with all fields needed for update
  const headers = [
    'Event',
    'First Name',
    'Last Name',
    'Email',
    'Address Line 1',
    'Address Line 2',
    'City',
    'State',
    'Zip',
    'Date',
    'QTY',
    'Gross',
    'Fee',
    'Net',
    'Amount Paid',
    'Shipping',
    'Tracking',
  ]

  const rows = selectedOrders.value.map((order) => {
    const buyer = order.buyer
    const address = order.buyer_address
    const event = order.event
    const orderDate = order.order_date ? new Date(order.order_date).toLocaleDateString('en-US') : ''

    return [
      event?.name || '',
      buyer?.first_name || '',
      buyer?.last_name || '',
      buyer?.email || '',
      address?.address_line1 || '',
      address?.address_line2 || '',
      address?.city || '',
      address?.state || '',
      address?.postal_code || '',
      orderDate,
      order.quantity || '',
      order.total_price || '',
      order.fee || '',
      order.total_price || '', // Net = total_price
      order.amount_paid || '',
      order.actual_postage_cost || '',
      order.tracking_number || '',
    ]
  })

  // Create CSV content
  const csvContent = [
    headers.join(','),
    ...rows.map((row) => row.map((cell) => `"${String(cell).replace(/"/g, '""')}"`).join(',')),
  ].join('\n')

  // Create blob and download
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)
  link.setAttribute('href', url)
  link.setAttribute('download', `orders_update_${new Date().toISOString().split('T')[0]}.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)

  $q.notify({
    type: 'positive',
    message: `Exported ${selectedOrders.value.length} order(s) for update`,
  })
}

// Export selected orders to CSV/Excel
function exportSelectedOrders() {
  if (selectedOrders.value.length === 0) {
    $q.notify({
      type: 'warning',
      message: 'Please select orders to export',
    })
    return
  }

  // Generate CSV content
  const headers = [
    'FirstName',
    'LastName',
    'Address1',
    'Address2',
    'City',
    'State',
    'Zip',
    'Email',
    'Weight',
    'Length',
    'Width',
    'Stamp1',
    'Stamp2',
    'Stamp3',
  ]

  const rows = selectedOrders.value.map((order) => {
    const buyer = order.buyer
    const address = order.buyer_address
    const event = order.event
    const weight = order.weight || 0
    const length = order.length || 0
    const width = order.width || 0

    // Stamp 1 = Qty + Event Name (e.g., "3JC22 Bandana")
    const stamp1 = `${order.quantity}${event?.name || ''} Bandana`
    // Stamp 2 = Order Number
    const stamp2 = order.order_number || order.id.substring(0, 8)
    // Stamp 3 = Room Number
    const stamp3 = order.room_number || ''

    return [
      buyer?.first_name || '',
      buyer?.last_name || '',
      address?.address_line1 || '',
      address?.address_line2 || '',
      address?.city || '',
      address?.state || '',
      address?.postal_code || '',
      buyer?.email || '',
      weight,
      length,
      width,
      stamp1,
      stamp2,
      stamp3,
    ]
  })

  // Create CSV content
  const csvContent = [
    headers.join(','),
    ...rows.map((row) => row.map((cell) => `"${String(cell).replace(/"/g, '""')}"`).join(',')),
  ].join('\n')

  // Create blob and download
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)
  link.setAttribute('href', url)
  link.setAttribute('download', `orders_export_${new Date().toISOString().split('T')[0]}.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)

  // Update status to "Pending Shipping" for exported orders
  updateBulkStatus('Pending Shipping', selectedOrders.value)

  $q.notify({
    type: 'positive',
    message: `Exported ${selectedOrders.value.length} order(s) and updated status to Pending Shipping`,
  })
}

// Bulk status update
async function updateBulkStatus(status, orders = null) {
  const ordersToUpdate = orders || selectedOrders.value
  if (ordersToUpdate.length === 0) {
    $q.notify({
      type: 'warning',
      message: 'Please select orders to update',
    })
    return
  }

  try {
    const updates = ordersToUpdate.map((order) => ordersStore.updateOrder(order.id, { status }))
    await Promise.all(updates)
    await ordersStore.refetch()
    selectedOrders.value = []
    bulkStatusDialog.value = false
    $q.notify({
      type: 'positive',
      message: `Updated ${ordersToUpdate.length} order(s) to ${status}`,
    })
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Error updating orders: ' + error.message,
    })
  }
}

// Tracking import
const trackingFile = ref(null)
const trackingImporting = ref(false)
const trackingImportResults = ref(null)

async function handleTrackingImport() {
  if (!trackingFile.value) {
    $q.notify({
      type: 'warning',
      message: 'Please select a file',
    })
    return
  }

  trackingImporting.value = true
  trackingImportResults.value = null

  try {
    const text = await trackingFile.value.text()
    const lines = text.split('\n').filter((line) => line.trim())
    if (lines.length < 2) {
      throw new Error('File must contain header row and at least one data row')
    }

    // Parse header
    const header = parseCSVLine(lines[0])
    const orderNumberIndex = header.findIndex(
      (h) => h.toLowerCase().includes('order') || h.toLowerCase().includes('stamp2'),
    )
    const trackingIndex = header.findIndex((h) => h.toLowerCase().includes('tracking'))
    // Look for shipping cost column - check for various possible names
    const shippingCostIndex = header.findIndex(
      (h) =>
        h.toLowerCase().includes('shipping') ||
        h.toLowerCase().includes('postage') ||
        (h.toLowerCase().includes('actual') && h.toLowerCase().includes('cost')) ||
        h.toLowerCase().includes('actual_postage') ||
        h.toLowerCase().includes('actual shipping'),
    )

    if (orderNumberIndex === -1) {
      throw new Error('Could not find Order Number column (look for "Order" or "Stamp2")')
    }
    if (trackingIndex === -1) {
      throw new Error('Could not find Tracking Number column')
    }

    const results = { success: 0, failed: 0, errors: [] }

    // Process each row
    for (let i = 1; i < lines.length; i++) {
      try {
        const row = parseCSVLine(lines[i])
        const orderNumber = row[orderNumberIndex]?.trim()
        const trackingNumber = row[trackingIndex]?.trim()
        const shippingCostValue = shippingCostIndex !== -1 ? row[shippingCostIndex]?.trim() : null

        if (!orderNumber) {
          results.failed++
          results.errors.push({
            row: i + 1,
            error: 'Order number is required',
          })
          continue
        }

        if (!trackingNumber) {
          results.failed++
          results.errors.push({
            row: i + 1,
            error: 'Tracking number is required',
          })
          continue
        }

        // Find order by order_number
        const order = ordersStore.orders.value.find((o) => o.order_number === orderNumber)

        if (!order) {
          results.failed++
          results.errors.push({
            row: i + 1,
            error: `Order with number "${orderNumber}" not found`,
          })
          continue
        }

        // Prepare update data
        const updateData = {
          tracking_number: trackingNumber,
          status: 'Tracking Created',
        }

        // Parse and add actual shipping cost if provided
        if (shippingCostValue) {
          const shippingCost = parseFloat(shippingCostValue)
          if (!isNaN(shippingCost) && shippingCost >= 0) {
            updateData.actual_postage_cost = shippingCost
          }
        }

        // Update order with tracking number, status, and shipping cost
        await ordersStore.updateOrder(order.id, updateData)

        results.success++
      } catch (error) {
        results.failed++
        results.errors.push({
          row: i + 1,
          error: error.message || 'Failed to process row',
        })
      }
    }

    trackingImportResults.value = results

    if (results.success > 0) {
      $q.notify({
        type: 'positive',
        message: `Successfully imported ${results.success} tracking number(s)`,
      })
      await ordersStore.refetch()
    }
  } catch (error) {
    console.error('Tracking import error:', error)
    trackingImportResults.value = {
      success: 0,
      failed: 0,
      errors: [{ row: 'N/A', error: error instanceof Error ? error.message : 'Import failed' }],
    }
    $q.notify({
      type: 'negative',
      message: 'Error importing tracking numbers: ' + error.message,
    })
  } finally {
    trackingImporting.value = false
  }
}

function closeTrackingDialog() {
  trackingImportDialog.value = false
  trackingFile.value = null
  trackingImportResults.value = null
}
</script>
