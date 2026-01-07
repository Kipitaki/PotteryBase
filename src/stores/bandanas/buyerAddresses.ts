import { computed } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery, useMutation } from '@vue/apollo-composable'
import { apolloClient } from 'boot/apollo'

provideApolloClient(apolloClient)

const BUYER_ADDRESSES = gql`
  query BuyerAddresses {
    bandanas_buyer_addresses(order_by: { created_at: desc }) {
      id
      buyer_id
      address_line1
      address_line2
      city
      state
      postal_code
      country
      original_address_id
      created_at
      updated_at
      buyer {
        id
        first_name
        last_name
        email
      }
    }
  }
`

const BUYER_ADDRESS_BY_ID = gql`
  query BuyerAddressById($id: uuid!) {
    bandanas_buyer_addresses_by_pk(id: $id) {
      id
      buyer_id
      address_line1
      address_line2
      city
      state
      postal_code
      country
      created_at
      updated_at
      buyer {
        id
        first_name
        last_name
        email
      }
    }
  }
`

const CREATE_BUYER_ADDRESS = gql`
  mutation CreateBuyerAddress($object: bandanas_buyer_addresses_insert_input!) {
    insert_bandanas_buyer_addresses_one(object: $object) {
      id
      buyer_id
      address_line1
      address_line2
      city
      state
      postal_code
      country
      original_address_id
      created_at
      updated_at
    }
  }
`

const UPDATE_BUYER_ADDRESS = gql`
  mutation UpdateBuyerAddress($id: uuid!, $changes: bandanas_buyer_addresses_set_input!) {
    update_bandanas_buyer_addresses_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
      address_line1
      address_line2
      city
      state
      postal_code
      country
      updated_at
    }
  }
`

const DELETE_BUYER_ADDRESS = gql`
  mutation DeleteBuyerAddress($id: uuid!) {
    delete_bandanas_buyer_addresses_by_pk(id: $id) {
      id
    }
  }
`

const DELETE_ALL_ADDRESSES = gql`
  mutation DeleteAllAddresses {
    delete_bandanas_buyer_addresses(where: {}) {
      affected_rows
    }
  }
`

const ADDRESS_BY_ORIGINAL_ID = gql`
  query AddressByOriginalId($original_address_id: String!) {
    bandanas_buyer_addresses(where: { original_address_id: { _eq: $original_address_id } }, limit: 1) {
      id
      buyer_id
      original_address_id
    }
  }
`

export function useBuyerAddressesStore() {
  const { result, loading, error, refetch } = useQuery(BUYER_ADDRESSES, null, {
    fetchPolicy: 'network-only',
  })

  const { mutate: createBuyerAddressMut } = useMutation(CREATE_BUYER_ADDRESS)
  const { mutate: updateBuyerAddressMut } = useMutation(UPDATE_BUYER_ADDRESS)
  const { mutate: deleteBuyerAddressMut } = useMutation(DELETE_BUYER_ADDRESS)
  const { mutate: deleteAllAddressesMut } = useMutation(DELETE_ALL_ADDRESSES)

  const buyerAddresses = computed(() => result.value?.bandanas_buyer_addresses ?? [])

  async function createBuyerAddress(data: {
    buyer_id: string
    address_line1: string
    address_line2?: string | null
    city: string
    state?: string | null
    postal_code: string
    country?: string
    original_address_id?: string | null
  }) {
    const { data: result } = await createBuyerAddressMut({ object: data })
    await refetch()
    return result?.insert_bandanas_buyer_addresses_one
  }

  async function updateBuyerAddress(id: string, changes: {
    buyer_id?: string
    address_line1?: string
    address_line2?: string | null
    city?: string
    state?: string | null
    postal_code?: string
    country?: string
    original_address_id?: string | null
  }) {
    const { data: result } = await updateBuyerAddressMut({ id, changes })
    await refetch()
    return result?.update_bandanas_buyer_addresses_by_pk
  }

  async function deleteBuyerAddress(id: string) {
    await deleteBuyerAddressMut({ id })
    await refetch()
  }

  async function deleteAllAddresses() {
    await deleteAllAddressesMut()
    await refetch()
  }

  async function getAddressByOriginalId(originalAddressId: string) {
    const { data } = await apolloClient.query({
      query: ADDRESS_BY_ORIGINAL_ID,
      variables: { original_address_id: originalAddressId },
      fetchPolicy: 'network-only',
    })
    return data?.bandanas_buyer_addresses?.[0] || null
  }

  return {
    buyerAddresses,
    loading,
    error,
    refetch,
    createBuyerAddress,
    updateBuyerAddress,
    deleteBuyerAddress,
    deleteAllAddresses,
    getAddressByOriginalId,
  }
}

