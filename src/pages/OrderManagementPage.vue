<template>
  <q-page class="orders-page q-pa-md">
    <div class="q-mb-md">
      <div class="text-h4">Orders</div>
      <div class="text-caption text-grey-7 q-mt-xs">
        View and manage your orders
      </div>
    </div>

    <div v-if="ordersStore.loading" class="flex flex-center q-pa-xl">
      <q-spinner-dots size="3em" color="primary" />
    </div>

    <div v-else-if="ordersStore.orders.length === 0" class="flex flex-center column q-pa-xl">
      <q-icon name="receipt_long" size="4em" color="grey-5" class="q-mb-md" />
      <div class="text-h6 text-grey-7">No orders yet</div>
      <q-btn
        color="primary"
        label="Start Shopping"
        @click="$router.push({ name: 'gallery' })"
        class="q-mt-md"
      />
    </div>

    <div v-else>
      <q-table
        :rows="ordersStore.orders"
        :columns="columns"
        row-key="id"
        flat
        :rows-per-page-options="[10, 25, 50]"
      >
        <template v-slot:body-cell-order_number="props">
          <q-td :props="props">
            <div class="text-weight-medium">{{ props.value }}</div>
            <div class="text-caption text-grey-6">
              {{ formatDate(props.row.created_at) }}
            </div>
          </q-td>
        </template>

        <template v-slot:body-cell-status="props">
          <q-td :props="props">
            <q-chip
              :color="getStatusColor(props.value)"
              text-color="white"
              :label="props.value"
              size="sm"
            />
          </q-td>
        </template>

        <template v-slot:body-cell-total="props">
          <q-td :props="props">
            <div class="text-weight-bold">${{ formatPrice(props.value) }}</div>
          </q-td>
        </template>

        <template v-slot:body-cell-actions="props">
          <q-td :props="props">
            <q-btn
              flat
              dense
              round
              icon="visibility"
              @click="viewOrder(props.row)"
            />
          </q-td>
        </template>
      </q-table>
    </div>

    <!-- Order Details Dialog -->
    <q-dialog v-model="orderDialog" maximized>
      <q-card v-if="selectedOrder">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Order {{ selectedOrder.order_number }}</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section>
          <div class="row q-col-gutter-md">
            <div class="col-12 col-md-6">
              <div class="text-subtitle2 q-mb-sm">Order Information</div>
              <div class="q-mb-xs">
                <strong>Status:</strong>
                <q-chip
                  :color="getStatusColor(selectedOrder.status)"
                  text-color="white"
                  :label="selectedOrder.status"
                  size="sm"
                  class="q-ml-sm"
                />
              </div>
              <div class="q-mb-xs">
                <strong>Order Date:</strong> {{ formatDate(selectedOrder.created_at) }}
              </div>
              <div class="q-mb-xs">
                <strong>Shipping Method:</strong>
                {{ selectedOrder.shipping_method === 'shipping' ? 'Shipping' : 'Pickup' }}
              </div>
            </div>

            <div v-if="selectedOrder.shipping_address" class="col-12 col-md-6">
              <div class="text-subtitle2 q-mb-sm">Shipping Address</div>
              <div>{{ selectedOrder.shipping_address.name }}</div>
              <div>{{ selectedOrder.shipping_address.street_address }}</div>
              <div>
                {{ selectedOrder.shipping_address.city }}, {{ selectedOrder.shipping_address.state }}
                {{ selectedOrder.shipping_address.zip_code }}
              </div>
            </div>
          </div>

          <q-separator class="q-my-md" />

          <div class="text-subtitle2 q-mb-sm">Order Items</div>
          <q-list>
            <q-item
              v-for="item in selectedOrder.order_items"
              :key="item.id"
              class="q-pa-md"
            >
              <q-item-section avatar>
                <q-img
                  v-if="item.piece?.piece_images?.[0]?.url"
                  :src="item.piece.piece_images[0].url"
                  style="width: 60px; height: 60px"
                  fit="cover"
                />
              </q-item-section>
              <q-item-section>
                <q-item-label>{{ item.piece?.title || 'Untitled' }}</q-item-label>
                <q-item-label caption>
                  Quantity: {{ item.quantity }} × ${{ formatPrice(item.price) }}
                </q-item-label>
              </q-item-section>
              <q-item-section side>
                <div class="text-weight-medium">${{ formatPrice(item.subtotal) }}</div>
              </q-item-section>
            </q-item>
          </q-list>

          <q-separator class="q-my-md" />

          <div class="row justify-end q-gutter-md">
            <div class="text-body2">
              <div class="row justify-between q-mb-xs">
                <span>Subtotal:</span>
                <span>${{ formatPrice(selectedOrder.subtotal) }}</span>
              </div>
              <div class="row justify-between q-mb-xs">
                <span>Tax:</span>
                <span>${{ formatPrice(selectedOrder.tax_amount) }}</span>
              </div>
              <div class="row justify-between q-mb-xs">
                <span>Shipping:</span>
                <span>${{ formatPrice(selectedOrder.shipping_amount) }}</span>
              </div>
              <q-separator class="q-my-xs" />
              <div class="row justify-between text-h6">
                <span>Total:</span>
                <span>${{ formatPrice(selectedOrder.total) }}</span>
              </div>
            </div>
          </div>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref } from 'vue'
import { useOrdersStore } from 'src/stores/orders'

const ordersStore = useOrdersStore()

const orderDialog = ref(false)
const selectedOrder = ref(null)

const columns = [
  {
    name: 'order_number',
    label: 'Order #',
    field: 'order_number',
    align: 'left',
    sortable: true,
  },
  {
    name: 'status',
    label: 'Status',
    field: 'status',
    align: 'center',
    sortable: true,
  },
  {
    name: 'total',
    label: 'Total',
    field: 'total',
    align: 'right',
    sortable: true,
  },
  {
    name: 'actions',
    label: 'Actions',
    field: 'actions',
    align: 'center',
  },
]

function formatPrice(price) {
  return price.toFixed(2)
}

function formatDate(date) {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  })
}

function getStatusColor(status) {
  const colors = {
    pending: 'orange',
    paid: 'blue',
    processing: 'purple',
    shipped: 'teal',
    delivered: 'green',
    cancelled: 'red',
  }
  return colors[status] || 'grey'
}

function viewOrder(order) {
  selectedOrder.value = order
  orderDialog.value = true
}
</script>

<style scoped>
.orders-page {
  max-width: 1400px;
  margin: 0 auto;
}
</style>

