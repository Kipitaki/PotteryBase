<template>
  <q-page class="checkout-page q-pa-md">
    <div class="q-mb-md">
      <div class="text-h4">Checkout</div>
    </div>

    <div v-if="cartStore.loading" class="flex flex-center q-pa-xl">
      <q-spinner-dots size="3em" color="primary" />
    </div>

    <div v-else-if="cartStore.items.length === 0" class="flex flex-center column q-pa-xl">
      <q-icon name="shopping_cart" size="4em" color="grey-5" class="q-mb-md" />
      <div class="text-h6 text-grey-7">Your cart is empty</div>
      <q-btn
        color="primary"
        label="Continue Shopping"
        @click="$router.push({ name: 'gallery' })"
        class="q-mt-md"
      />
    </div>

    <div v-else class="row q-col-gutter-md">
      <!-- Checkout Form -->
      <div class="col-12 col-md-7">
        <q-card class="q-mb-md">
          <q-card-section>
            <div class="text-h6">Shipping Information</div>
          </q-card-section>
          <q-card-section>
            <q-radio
              v-model="shippingMethod"
              val="shipping"
              label="Ship to address"
              class="q-mb-md"
            />
            <q-radio
              v-model="shippingMethod"
              val="pickup"
              label="Local pickup"
              class="q-mb-md"
            />

            <div v-if="shippingMethod === 'shipping'" class="q-mt-md">
              <q-input
                v-model="shippingAddress.name"
                label="Full Name *"
                outlined
                class="q-mb-sm"
                :rules="[(val) => !!val || 'Name is required']"
              />
              <q-input
                v-model="shippingAddress.street_address"
                label="Street Address *"
                outlined
                class="q-mb-sm"
                :rules="[(val) => !!val || 'Address is required']"
              />
              <div class="row q-col-gutter-sm">
                <div class="col-8">
                  <q-input
                    v-model="shippingAddress.city"
                    label="City *"
                    outlined
                    class="q-mb-sm"
                    :rules="[(val) => !!val || 'City is required']"
                  />
                </div>
                <div class="col-4">
                  <q-input
                    v-model="shippingAddress.state"
                    label="State *"
                    outlined
                    value="FL"
                    readonly
                    class="q-mb-sm"
                  />
                </div>
              </div>
              <q-input
                v-model="shippingAddress.zip_code"
                label="ZIP Code *"
                outlined
                class="q-mb-sm"
                :rules="[(val) => !!val || 'ZIP code is required']"
              />
              <q-input
                v-model="shippingAddress.phone"
                label="Phone (optional)"
                outlined
                class="q-mb-sm"
              />
            </div>
          </q-card-section>
        </q-card>

        <q-card>
          <q-card-section>
            <div class="text-h6">Payment</div>
            <div class="text-caption text-grey-7 q-mt-xs">
              Square payment integration will be added here
            </div>
            <!-- Square payment form will be integrated here -->
            <div id="square-payment-form" class="q-mt-md"></div>
          </q-card-section>
        </q-card>
      </div>

      <!-- Order Summary -->
      <div class="col-12 col-md-5">
        <q-card class="sticky-summary">
          <q-card-section>
            <div class="text-h6">Order Summary</div>
          </q-card-section>
          <q-card-section>
            <q-list>
              <q-item v-for="item in cartStore.items" :key="item.id" dense>
                <q-item-section avatar>
                  <q-img
                    v-if="item.piece?.piece_images?.[0]?.url"
                    :src="item.piece.piece_images[0].url"
                    style="width: 50px; height: 50px"
                    fit="cover"
                  />
                </q-item-section>
                <q-item-section>
                  <q-item-label>{{ item.piece?.title || 'Untitled' }}</q-item-label>
                  <q-item-label caption>
                    Qty: {{ item.quantity }} × ${{ formatPrice(item.piece?.price || 0) }}
                  </q-item-label>
                </q-item-section>
                <q-item-section side>
                  <div class="text-weight-medium">
                    ${{ formatPrice((item.piece?.price || 0) * item.quantity) }}
                  </div>
                </q-item-section>
              </q-item>
            </q-list>
            <q-separator class="q-my-md" />
            <div class="row justify-between q-mb-sm">
              <div>Subtotal:</div>
              <div class="text-weight-medium">${{ formatPrice(cartStore.subtotal) }}</div>
            </div>
            <div class="row justify-between q-mb-sm">
              <div>Tax (6%):</div>
              <div class="text-weight-medium">${{ formatPrice(taxAmount) }}</div>
            </div>
            <div v-if="shippingMethod === 'shipping'" class="row justify-between q-mb-sm">
              <div>Shipping:</div>
              <div class="text-weight-medium">TBD</div>
            </div>
            <q-separator class="q-my-md" />
            <div class="row justify-between">
              <div class="text-h6">Total:</div>
              <div class="text-h6 text-weight-bold">${{ formatPrice(total) }}</div>
            </div>
          </q-card-section>
          <q-card-actions vertical>
            <q-btn
              color="primary"
              label="Complete Order"
              size="lg"
              :loading="processing"
              :disable="!canCompleteOrder"
              @click="processPayment"
              class="full-width"
            />
            <q-btn
              flat
              label="Back to Cart"
              @click="$router.push({ name: 'cart' })"
              class="full-width q-mt-sm"
            />
          </q-card-actions>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { useCartStore } from 'src/stores/cart'
import { useOrdersStore } from 'src/stores/orders'

const router = useRouter()
const $q = useQuasar()
const cartStore = useCartStore()
const ordersStore = useOrdersStore()

const shippingMethod = ref('shipping')
const processing = ref(false)

const shippingAddress = ref({
  name: '',
  street_address: '',
  city: '',
  state: 'FL',
  zip_code: '',
  phone: '',
})

const taxAmount = computed(() => {
  return cartStore.subtotal * 0.06 // Florida 6% tax
})

const shippingAmount = computed(() => {
  // Shipping will be calculated via Square/PirateShip integration
  return shippingMethod.value === 'shipping' ? 0 : 0 // Placeholder
})

const total = computed(() => {
  return cartStore.subtotal + taxAmount.value + shippingAmount.value
})

const canCompleteOrder = computed(() => {
  if (shippingMethod.value === 'shipping') {
    return (
      shippingAddress.value.name &&
      shippingAddress.value.street_address &&
      shippingAddress.value.city &&
      shippingAddress.value.zip_code
    )
  }
  return true
})

function formatPrice(price) {
  return price.toFixed(2)
}

async function processPayment() {
  if (!canCompleteOrder.value) {
    $q.notify({
      type: 'negative',
      message: 'Please fill in all required fields',
      position: 'top',
    })
    return
  }

  processing.value = true
  try {
    // TODO: Integrate Square payment processing
    // For now, create order without payment
    const orderData = {
      order_number: `ORD-${Date.now()}`,
      status: 'pending',
      subtotal: cartStore.subtotal,
      tax_amount: taxAmount.value,
      shipping_amount: shippingAmount.value,
      total: total.value,
      shipping_method: shippingMethod.value,
      shipping_address: shippingMethod.value === 'shipping' ? shippingAddress.value : null,
    }

    await ordersStore.createOrder(orderData)
    
    // Clear cart
    await cartStore.clearCart()

    $q.notify({
      type: 'positive',
      message: 'Order placed successfully!',
      position: 'top',
      timeout: 3000,
    })

    router.push({ name: 'orders' })
  } catch (error) {
    console.error('Error processing payment:', error)
    $q.notify({
      type: 'negative',
      message: 'Failed to process order. Please try again.',
      position: 'top',
    })
  } finally {
    processing.value = false
  }
}
</script>

<style scoped>
.checkout-page {
  max-width: 1200px;
  margin: 0 auto;
}

.sticky-summary {
  position: sticky;
  top: 20px;
}
</style>

