<template>
  <q-page class="cart-page q-pa-md">
    <div class="q-mb-md">
      <div class="text-h4">Shopping Cart</div>
      <div class="text-caption text-grey-7 q-mt-xs">Review your items before checkout</div>
    </div>

    <div v-if="cartStore.loading" class="flex flex-center q-pa-xl">
      <q-spinner-dots size="3em" color="primary" />
    </div>

    <div v-else-if="cartStore.error" class="flex flex-center column q-pa-xl">
      <q-icon name="error" size="4em" color="negative" class="q-mb-md" />
      <div class="text-h6 text-negative">Error loading cart</div>
      <div class="text-body2 text-grey-7 q-mt-sm">
        {{ cartStore.error?.message || 'Unknown error' }}
      </div>
      <q-btn color="primary" label="Try Again" @click="cartStore.refetch()" class="q-mt-md" />
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
      <!-- Cart Items -->
      <div class="col-12 col-md-8">
        <q-card>
          <q-card-section>
            <div class="text-h6">Cart Items</div>
          </q-card-section>
          <q-list separator>
            <q-item v-for="item in cartStore.items" :key="item.id" class="q-pa-md">
              <q-item-section avatar>
                <q-img
                  v-if="
                    item.piece?.piece_images &&
                    item.piece.piece_images.length > 0 &&
                    item.piece.piece_images[0]?.url
                  "
                  :src="item.piece.piece_images[0].url"
                  style="width: 80px; height: 80px"
                  fit="cover"
                  class="rounded-borders"
                />
                <q-icon v-else name="image" size="80px" color="grey-4" />
              </q-item-section>

              <q-item-section>
                <q-item-label class="text-weight-medium">{{
                  item.piece?.title || 'Untitled'
                }}</q-item-label>
                <q-item-label caption>
                  <span v-if="!item.piece?.in_stock" class="text-negative">Out of Stock</span>
                  <span v-else-if="!item.piece?.is_for_sale" class="text-grey">Not for Sale</span>
                </q-item-label>
              </q-item-section>

              <q-item-section side>
                <div class="text-h6 text-weight-bold">
                  ${{ formatPrice(item.piece?.price || 0) }}
                </div>
              </q-item-section>

              <q-item-section side>
                <q-input
                  v-model.number="item.quantity"
                  type="number"
                  min="1"
                  dense
                  outlined
                  style="width: 80px"
                  @update:model-value="updateQuantity(item.id, $event)"
                />
              </q-item-section>

              <q-item-section side>
                <q-btn flat round icon="delete" color="negative" @click="removeItem(item.id)" />
              </q-item-section>
            </q-item>
          </q-list>
        </q-card>
      </div>

      <!-- Order Summary -->
      <div class="col-12 col-md-4">
        <q-card>
          <q-card-section>
            <div class="text-h6">Order Summary</div>
          </q-card-section>
          <q-card-section>
            <div class="row justify-between q-mb-sm">
              <div>Subtotal:</div>
              <div class="text-weight-medium">${{ formatPrice(cartStore.subtotal) }}</div>
            </div>
            <div class="row justify-between q-mb-sm">
              <div>Tax (6%):</div>
              <div class="text-weight-medium">${{ formatPrice(taxAmount) }}</div>
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
              label="Proceed to Checkout"
              size="lg"
              :disable="!canCheckout"
              @click="goToCheckout"
              class="full-width"
            />
            <q-btn
              flat
              label="Continue Shopping"
              @click="$router.push({ name: 'gallery' })"
              class="full-width q-mt-sm"
            />
          </q-card-actions>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { computed, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { useCartStore } from 'src/stores/cart'
import { nhost } from 'boot/nhost'

const router = useRouter()
const $q = useQuasar()
const cartStore = useCartStore()

// Manually trigger fetch when component mounts
onMounted(async () => {
  console.log('[CartPage] Mounted - triggering cart fetch')
  if (nhost.auth.isAuthenticated() && cartStore.items.length === 0 && !cartStore.loading) {
    await cartStore.refetch()
  }
})

// Debug: Log cart store state
watch(
  () => cartStore.loading,
  (loading) => {
    console.log('[CartPage] Loading:', loading)
  },
)
watch(
  () => cartStore.error,
  (error) => {
    if (error) console.error('[CartPage] Error:', error)
  },
)
watch(
  () => cartStore.items,
  (items) => {
    console.log('[CartPage] Items:', items)
  },
)
console.log('[CartPage] Is authenticated:', nhost.auth.isAuthenticated())
console.log('[CartPage] Cart store loading:', cartStore.loading?.value ?? cartStore.loading)
console.log('[CartPage] Cart store error:', cartStore.error?.value ?? cartStore.error)
console.log('[CartPage] Cart store items:', cartStore.items?.value ?? cartStore.items)

const taxAmount = computed(() => {
  return cartStore.subtotal * 0.06 // Florida 6% tax
})

const total = computed(() => {
  return cartStore.subtotal + taxAmount.value
})

const canCheckout = computed(() => {
  return (
    cartStore.items.length > 0 &&
    cartStore.items.every((item) => item.piece?.in_stock && item.piece?.is_for_sale)
  )
})

function formatPrice(price) {
  return price.toFixed(2)
}

async function updateQuantity(itemId, quantity) {
  if (quantity <= 0) {
    removeItem(itemId)
    return
  }
  try {
    await cartStore.updateQuantity(itemId, quantity)
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Failed to update quantity',
      position: 'top',
    })
  }
}

async function removeItem(itemId) {
  try {
    await cartStore.removeFromCart(itemId)
    $q.notify({
      type: 'positive',
      message: 'Item removed from cart',
      position: 'top',
      timeout: 2000,
    })
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Failed to remove item',
      position: 'top',
    })
  }
}

function goToCheckout() {
  router.push({ name: 'checkout' })
}
</script>

<style scoped>
.cart-page {
  max-width: 1200px;
  margin: 0 auto;
}
</style>
