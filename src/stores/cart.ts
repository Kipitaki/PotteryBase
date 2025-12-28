import { ref, computed } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useMutation } from '@vue/apollo-composable'
import { apolloClient } from 'boot/nhost'
import { nhost } from 'boot/nhost'

provideApolloClient(apolloClient)

/* -------- Queries -------- */
const CART_ITEMS = gql`
  query CartItems {
    potterbase_cart(order_by: { created_at: desc }) {
      id
      piece_id
      quantity
      piece {
        id
        title
        price
        is_for_sale
        in_stock
        piece_images(where: { is_main: { _eq: true } }, limit: 1) {
          url
        }
      }
    }
  }
`

/* ---- Mutations ---- */
const ADD_TO_CART = gql`
  mutation AddToCart($piece_id: Int!, $quantity: Int!) {
    insert_potterbase_cart_one(
      object: { piece_id: $piece_id, quantity: $quantity }
      on_conflict: { constraint: cart_user_id_piece_id_key, update_columns: [quantity] }
    ) {
      id
      piece_id
      quantity
    }
  }
`

const UPDATE_CART_ITEM = gql`
  mutation UpdateCartItem($id: UUID!, $quantity: Int!) {
    update_potterbase_cart_by_pk(pk_columns: { id: $id }, _set: { quantity: $quantity }) {
      id
      quantity
    }
  }
`

const REMOVE_FROM_CART = gql`
  mutation RemoveFromCart($id: UUID!) {
    delete_potterbase_cart_by_pk(id: $id) {
      id
    }
  }
`

const CLEAR_CART = gql`
  mutation ClearCart {
    delete_potterbase_cart(where: {}) {
      affected_rows
    }
  }
`

// Singleton store instance
let storeInstance = null
let fetchInProgress = false

export function useCartStore() {
  // Return existing instance if already created
  if (storeInstance) {
    return storeInstance
  }

  const items = ref([])
  const loading = ref(false)
  const error = ref(null)

  async function fetchCart() {
    if (!nhost.auth.isAuthenticated()) {
      items.value = []
      loading.value = false
      return
    }

    // Prevent multiple simultaneous fetches
    if (fetchInProgress) {
      return
    }

    fetchInProgress = true
    loading.value = true
    error.value = null

    try {
      const client = await apolloClient
      const result = await client.query({
        query: CART_ITEMS,
        fetchPolicy: 'network-only',
      })
      console.log('[Cart Store] Query completed, data:', result.data)
      items.value = result.data?.potterbase_cart || []
      console.log('[Cart Store] Items.value set to:', items.value)
    } catch (err) {
      console.error('[Cart Store] Error fetching cart:', err)
      error.value = err
      items.value = []
    } finally {
      loading.value = false
      fetchInProgress = false
    }
  }

  // Initialize fetch once when store is created
  let initialized = false
  if (!initialized) {
    initialized = true
    nhost.auth
      .waitUntilReady()
      .then(() => {
        if (nhost.auth.isAuthenticated()) {
          fetchCart()
        }
      })
      .catch((err) => {
        console.error('[Cart Store] Error waiting for auth:', err)
      })
  }

  const { mutate: addToCartMutation } = useMutation(ADD_TO_CART)
  const { mutate: updateCartItemMutation } = useMutation(UPDATE_CART_ITEM)
  const { mutate: removeFromCartMutation } = useMutation(REMOVE_FROM_CART)
  const { mutate: clearCartMutation } = useMutation(CLEAR_CART)

  const itemCount = computed(() => items.value.reduce((sum, item) => sum + item.quantity, 0))
  const subtotal = computed(() => {
    return items.value.reduce((sum, item) => {
      const price = item.piece?.price || 0
      return sum + price * item.quantity
    }, 0)
  })

  async function addToCart(pieceId: number, quantity: number = 1) {
    try {
      await addToCartMutation({ piece_id: pieceId, quantity })
      await fetchCart()
    } catch (err) {
      console.error('Error adding to cart:', err)
      throw err
    }
  }

  async function updateQuantity(cartItemId: string, quantity: number) {
    if (quantity <= 0) {
      return removeFromCart(cartItemId)
    }
    try {
      await updateCartItemMutation({ id: cartItemId, quantity })
      await fetchCart()
    } catch (err) {
      console.error('Error updating cart item:', err)
      throw err
    }
  }

  async function removeFromCart(cartItemId: string) {
    try {
      await removeFromCartMutation({ id: cartItemId })
      await fetchCart()
    } catch (err) {
      console.error('Error removing from cart:', err)
      throw err
    }
  }

  async function clearCart() {
    try {
      await clearCartMutation()
      await fetchCart()
    } catch (err) {
      console.error('Error clearing cart:', err)
      throw err
    }
  }

  storeInstance = {
    items,
    itemCount,
    subtotal,
    loading,
    error,
    refetch: fetchCart,
    addToCart,
    updateQuantity,
    removeFromCart,
    clearCart,
  }

  return storeInstance
}
