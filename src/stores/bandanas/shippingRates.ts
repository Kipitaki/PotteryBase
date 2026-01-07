import { computed } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery, useMutation } from '@vue/apollo-composable'
import { apolloClient } from 'boot/apollo'

provideApolloClient(apolloClient)

const SHIPPING_RATES = gql`
  query ShippingRates {
    bandanas_shipping_rates(order_by: { quantity: asc, zone: asc }) {
      id
      quantity
      zone
      cost
      created_at
      updated_at
    }
  }
`

const CREATE_SHIPPING_RATE = gql`
  mutation CreateShippingRate($object: bandanas_shipping_rates_insert_input!) {
    insert_bandanas_shipping_rates_one(object: $object) {
      id
      quantity
      zone
      cost
      created_at
      updated_at
    }
  }
`

const UPDATE_SHIPPING_RATE = gql`
  mutation UpdateShippingRate($id: uuid!, $changes: bandanas_shipping_rates_set_input!) {
    update_bandanas_shipping_rates_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
      quantity
      zone
      cost
      updated_at
    }
  }
`

const DELETE_SHIPPING_RATE = gql`
  mutation DeleteShippingRate($id: uuid!) {
    delete_bandanas_shipping_rates_by_pk(id: $id) {
      id
    }
  }
`

export function useShippingRatesStore() {
  const { result, loading, error, refetch } = useQuery(SHIPPING_RATES, null, {
    fetchPolicy: 'network-only',
  })

  const { mutate: createShippingRateMut } = useMutation(CREATE_SHIPPING_RATE)
  const { mutate: updateShippingRateMut } = useMutation(UPDATE_SHIPPING_RATE)
  const { mutate: deleteShippingRateMut } = useMutation(DELETE_SHIPPING_RATE)

  const shippingRates = computed(() => result.value?.bandanas_shipping_rates ?? [])

  /**
   * Find shipping rate for a given quantity and zone
   * @param quantity - Order quantity
   * @param zone - USPS zone (1-9)
   * @returns Shipping rate cost or null if not found
   */
  function findRate(quantity: number, zone: number) {
    if (!quantity || !zone || quantity <= 0 || zone < 1 || zone > 9) {
      return null
    }

    // Find the exact match for quantity and zone
    const rate = shippingRates.value.find(
      (r) => r.quantity === quantity && r.zone === zone
    )

    return rate?.cost || null
  }

  async function createShippingRate(data: {
    quantity: number
    zone: number
    cost: number
  }) {
    const { data: result } = await createShippingRateMut({ object: data })
    await refetch()
    return result?.insert_bandanas_shipping_rates_one
  }

  async function updateShippingRate(id: string, changes: {
    quantity?: number
    zone?: number
    cost?: number
  }) {
    const { data: result } = await updateShippingRateMut({ id, changes })
    await refetch()
    return result?.update_bandanas_shipping_rates_by_pk
  }

  async function deleteShippingRate(id: string) {
    await deleteShippingRateMut({ id })
    await refetch()
  }

  return {
    shippingRates,
    loading,
    error,
    refetch,
    findRate,
    createShippingRate,
    updateShippingRate,
    deleteShippingRate,
  }
}

