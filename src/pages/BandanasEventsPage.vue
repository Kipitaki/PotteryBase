<template>
  <q-page padding class="bg-grey-1 bandanas-page">
    <div class="row items-center justify-between q-mb-md">
      <div>
        <div class="text-h5 text-weight-bold">Events</div>
        <div class="text-caption text-grey-7 q-mt-xs">Manage bandana events and pricing</div>
      </div>
      <q-btn
        color="purple"
        icon="add"
        label="Add Event"
        @click="router.push({ name: 'bandanas-event-edit', params: { id: 'new' } })"
      />
    </div>

    <q-table
      :rows="eventsStore.events.value"
      :columns="columns"
      row-key="id"
      :loading="eventsStore.loading.value"
      flat
      bordered
      :rows-per-page-options="[10, 25, 50]"
      :pagination="{ rowsPerPage: 25 }"
    >
      <template v-slot:body-cell-pricing="props">
        <q-td :props="props">
          <div>Single: ${{ props.row.price_single }}</div>
          <div>Multi: ${{ props.row.price_multi }}</div>
        </q-td>
      </template>
      <template v-slot:body-cell-active="props">
        <q-td :props="props">
          <q-chip
            :color="props.row.active ? 'positive' : 'grey'"
            text-color="white"
            :label="props.row.active ? 'Active' : 'Inactive'"
          />
        </q-td>
      </template>
      <template v-slot:body-cell-profit_loss="props">
        <q-td :props="props">
          <div
            :class="[
              'text-weight-medium',
              calculateProfitLoss(props.row) >= 0 ? 'text-positive' : 'text-negative'
            ]"
          >
            ${{ formatCurrency(calculateProfitLoss(props.row)) }}
          </div>
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
            @click="router.push({ name: 'bandanas-event-edit', params: { id: props.row.id } })"
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

  <q-dialog v-model="showDeleteConfirm" persistent>
    <q-card>
      <q-card-section>
        <div class="text-h6">Delete Event</div>
      </q-card-section>
      <q-card-section>
        Are you sure you want to delete {{ eventToDelete?.name }} ({{ eventToDelete?.year }})?
      </q-card-section>
      <q-card-actions align="right">
        <q-btn flat label="Cancel" color="purple" v-close-popup />
        <q-btn flat label="Delete" color="negative" :loading="deleting" @click="handleDelete" />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useEventsStore } from 'src/stores/bandanas/events'
import { useOrdersStore } from 'src/stores/bandanas/orders'
import { useQuasar } from 'quasar'

const router = useRouter()
const $q = useQuasar()
const eventsStore = useEventsStore()
const ordersStore = useOrdersStore()

const showDeleteConfirm = ref(false)
const eventToDelete = ref(null)
const deleting = ref(false)

const columns = [
  {
    name: 'name',
    label: 'Event Name',
    field: 'name',
    align: 'left',
    sortable: true,
  },
  {
    name: 'year',
    label: 'Year',
    field: 'year',
    align: 'left',
    sortable: true,
  },
  {
    name: 'pricing',
    label: 'Pricing',
    field: 'pricing',
    align: 'left',
  },
  {
    name: 'active',
    label: 'Status',
    field: 'active',
    align: 'center',
  },
  {
    name: 'created_at',
    label: 'Created',
    field: 'created_at',
    align: 'left',
    sortable: true,
    format: (val) => new Date(val).toLocaleDateString(),
  },
  {
    name: 'profit_loss',
    label: 'Profit/Loss',
    field: 'profit_loss',
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

// Format currency helper
function formatCurrency(value) {
  if (value === null || value === undefined || isNaN(value)) {
    return '0.00'
  }
  return Number(value).toFixed(2)
}

// Calculate profit/loss for an event
function calculateProfitLoss(event) {
  if (!event || !event.id) {
    return 0
  }

  // Get orders for this event
  const eventOrders = ordersStore.orders.value.filter((order) => order.event_id === event.id)
  
  if (eventOrders.length === 0) {
    return 0
  }

  // Calculate event costs
  const cost = parseFloat(event.bandana_cost) || 0
  const freight = parseFloat(event.freight) || 0
  const fees = parseFloat(event.fee_tax_transaction_fees) || 0
  const totalCost = cost + freight + fees

  // Calculate total paid from orders
  const totalPaid = eventOrders.reduce(
    (sum, order) => sum + (parseFloat(order.amount_paid) || 0),
    0
  )

  // Calculate total shipping charges (use actual if available, otherwise estimated)
  const totalShippingCharges = eventOrders.reduce((sum, order) => {
    const actual = parseFloat(order.actual_postage_cost)
    const estimated = parseFloat(order.estimated_postage_cost)
    const shippingCost = (actual && !isNaN(actual)) 
      ? actual 
      : (estimated && !isNaN(estimated) ? estimated : 0)
    return sum + shippingCost
  }, 0)

  // Get freight_out
  const freightOut = parseFloat(event.freight_out) || 0

  // Calculate net profit/loss
  return totalPaid - totalCost - totalShippingCharges - freightOut
}

function confirmDelete(event) {
  eventToDelete.value = event
  showDeleteConfirm.value = true
}

async function handleDelete() {
  if (!eventToDelete.value) return
  deleting.value = true
  try {
    await eventsStore.deleteEvent(eventToDelete.value.id)
    $q.notify({
      type: 'positive',
      message: 'Event deleted successfully',
    })
    showDeleteConfirm.value = false
    eventToDelete.value = null
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Error deleting event: ' + error.message,
    })
  } finally {
    deleting.value = false
  }
}
</script>
