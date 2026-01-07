import { computed } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery, useMutation } from '@vue/apollo-composable'
import { apolloClient } from 'boot/apollo'

provideApolloClient(apolloClient)

const ORDERS = gql`
  query Orders {
    bandanas_orders(order_by: { order_date: desc }) {
      id
      buyer_id
      address_id
      event_id
      order_date
      quantity
      total_price
      amount_paid
      fee
      payment_method
      room_number
      status
      order_number
      tracking_number
      usps_zone
      length
      width
      height
      weight
      estimated_postage_cost
      actual_postage_cost
      notes
      created_at
      updated_at
      buyer {
        id
        first_name
        last_name
        email
      }
      buyer_address {
        id
        address_line1
        address_line2
        city
        state
        postal_code
        country
      }
      event {
        id
        name
        year
        price_single
        price_multi
      }
    }
  }
`

const ORDER_BY_ID = gql`
  query OrderById($id: uuid!) {
    bandanas_orders_by_pk(id: $id) {
      id
      buyer_id
      address_id
      event_id
      order_date
      quantity
      total_price
      amount_paid
      fee
      payment_method
      room_number
      status
      order_number
      tracking_number
      usps_zone
      length
      width
      height
      weight
      estimated_postage_cost
      actual_postage_cost
      notes
      created_at
      updated_at
      buyer {
        id
        first_name
        last_name
        email
      }
      buyer_address {
        id
        address_line1
        address_line2
        city
        state
        postal_code
        country
      }
      event {
        id
        name
        year
        price_single
        price_multi
      }
    }
  }
`

const CREATE_ORDER = gql`
  mutation CreateOrder($object: bandanas_orders_insert_input!) {
    insert_bandanas_orders_one(object: $object) {
      id
      buyer_id
      address_id
      event_id
      order_date
      quantity
      total_price
      amount_paid
      fee
      payment_method
      room_number
      status
      order_number
      tracking_number
      usps_zone
      length
      width
      height
      weight
      estimated_postage_cost
      actual_postage_cost
      notes
      created_at
      updated_at
    }
  }
`

const UPDATE_ORDER = gql`
  mutation UpdateOrder($id: uuid!, $changes: bandanas_orders_set_input!) {
    update_bandanas_orders_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
      buyer_id
      address_id
      event_id
      order_date
      quantity
      total_price
      amount_paid
      fee
      payment_method
      room_number
      status
      order_number
      tracking_number
      usps_zone
      length
      width
      height
      weight
      estimated_postage_cost
      actual_postage_cost
      notes
      updated_at
    }
  }
`

const DELETE_ORDER = gql`
  mutation DeleteOrder($id: uuid!) {
    delete_bandanas_orders_by_pk(id: $id) {
      id
    }
  }
`

const DELETE_ALL_ORDERS = gql`
  mutation DeleteAllOrders {
    delete_bandanas_orders(where: {}) {
      affected_rows
    }
  }
`

export function useOrdersStore() {
  const { result, loading, error, refetch } = useQuery(ORDERS, null, {
    fetchPolicy: 'network-only',
  })

  const { mutate: createOrderMut } = useMutation(CREATE_ORDER)
  const { mutate: updateOrderMut } = useMutation(UPDATE_ORDER)
  const { mutate: deleteOrderMut } = useMutation(DELETE_ORDER)
  const { mutate: deleteAllOrdersMut } = useMutation(DELETE_ALL_ORDERS)

  const orders = computed(() => result.value?.bandanas_orders ?? [])

  async function createOrder(data: {
    buyer_id: string
    address_id?: string | null
    event_id: string
    order_date?: string
    quantity: number
    total_price: number
    amount_paid: number
    fee?: number
    payment_method?: string | null
    room_number?: string | null
    status?: string | null
    order_number?: string | null
    tracking_number?: string | null
    usps_zone?: number | null
    length?: number | null
    width?: number | null
    height?: number | null
    weight?: number | null
    estimated_postage_cost?: number | null
    actual_postage_cost?: number | null
    notes?: string | null
  }) {
    const { data: result } = await createOrderMut({ object: data })
    await refetch()
    return result?.insert_bandanas_orders_one
  }

  async function updateOrder(id: string, changes: {
    buyer_id?: string
    address_id?: string | null
    event_id?: string
    order_date?: string
    quantity?: number
    total_price?: number
    amount_paid?: number
    fee?: number
    payment_method?: string | null
    room_number?: string | null
    status?: string | null
    order_number?: string | null
    tracking_number?: string | null
    usps_zone?: number | null
    length?: number | null
    width?: number | null
    height?: number | null
    weight?: number | null
    estimated_postage_cost?: number | null
    actual_postage_cost?: number | null
    notes?: string | null
  }) {
    const { data: result } = await updateOrderMut({ id, changes })
    await refetch()
    return result?.update_bandanas_orders_by_pk
  }

  async function deleteOrder(id: string) {
    await deleteOrderMut({ id })
    await refetch()
  }

  async function deleteAllOrders() {
    await deleteAllOrdersMut()
    await refetch()
  }

  return {
    orders,
    loading,
    error,
    refetch,
    createOrder,
    updateOrder,
    deleteOrder,
    deleteAllOrders,
  }
}

