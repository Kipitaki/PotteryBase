import { computed } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery, useMutation } from '@vue/apollo-composable'
import { apolloClient } from 'boot/apollo'

provideApolloClient(apolloClient)

/* -------- Queries -------- */
const ORDERS = gql`
  query Orders {
    potterbase_order(order_by: { created_at: desc }) {
      id
      order_number
      status
      subtotal
      tax_amount
      shipping_amount
      total
      shipping_method
      shipping_address
      created_at
      updated_at
      order_items {
        id
        piece_id
        quantity
        price
        subtotal
        piece {
          id
          title
          piece_images(where: { is_main: { _eq: true } }, limit: 1) {
            url
          }
        }
      }
    }
  }
`

const ORDER_BY_ID = gql`
  query OrderById($id: UUID!) {
    potterbase_order_by_pk(id: $id) {
      id
      order_number
      status
      subtotal
      tax_amount
      shipping_amount
      total
      shipping_method
      shipping_address
      square_payment_id
      square_order_id
      created_at
      updated_at
      order_items {
        id
        piece_id
        quantity
        price
        subtotal
        piece {
          id
          title
          piece_images(where: { is_main: { _eq: true } }, limit: 1) {
            url
          }
        }
      }
    }
  }
`

/* ---- Mutations ---- */
const CREATE_ORDER = gql`
  mutation CreateOrder($object: potterbase_order_insert_input!) {
    insert_potterbase_order_one(object: $object) {
      id
      order_number
      status
      total
    }
  }
`

const UPDATE_ORDER_STATUS = gql`
  mutation UpdateOrderStatus($id: UUID!, $status: String!) {
    update_potterbase_order_by_pk(pk_columns: { id: $id }, _set: { status: $status }) {
      id
      status
    }
  }
`

export function useOrdersStore() {
  const { result, refetch, loading } = useQuery(ORDERS)
  const { mutate: createOrderMutation } = useMutation(CREATE_ORDER)
  const { mutate: updateOrderStatusMutation } = useMutation(UPDATE_ORDER_STATUS)

  const orders = computed(() => result.value?.potterbase_order || [])

  async function createOrder(orderData: any) {
    try {
      const { data } = await createOrderMutation({ object: orderData })
      await refetch()
      return data?.insert_potterbase_order_one
    } catch (error) {
      console.error('Error creating order:', error)
      throw error
    }
  }

  async function updateOrderStatus(orderId: string, status: string) {
    try {
      await updateOrderStatusMutation({ id: orderId, status })
      await refetch()
    } catch (error) {
      console.error('Error updating order status:', error)
      throw error
    }
  }

  return {
    orders,
    loading,
    refetch,
    createOrder,
    updateOrderStatus,
  }
}

