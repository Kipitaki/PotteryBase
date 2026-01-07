import { computed, ref } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery, useMutation } from '@vue/apollo-composable'
import { apolloClient } from 'boot/apollo'

provideApolloClient(apolloClient)

const BUYERS = gql`
  query Buyers {
    bandanas_buyers(order_by: { created_at: desc }) {
      id
      first_name
      last_name
      email
      original_buyer_id
      created_at
      updated_at
    }
  }
`

const BUYER_BY_ID = gql`
  query BuyerById($id: uuid!) {
    bandanas_buyers_by_pk(id: $id) {
      id
      first_name
      last_name
      email
      original_buyer_id
      created_at
      updated_at
    }
  }
`

const CREATE_BUYER = gql`
  mutation CreateBuyer($object: bandanas_buyers_insert_input!) {
    insert_bandanas_buyers_one(object: $object) {
      id
      first_name
      last_name
      email
      original_buyer_id
      created_at
      updated_at
    }
  }
`

const UPDATE_BUYER = gql`
  mutation UpdateBuyer($id: uuid!, $changes: bandanas_buyers_set_input!) {
    update_bandanas_buyers_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
      first_name
      last_name
      email
      updated_at
    }
  }
`

const DELETE_BUYER = gql`
  mutation DeleteBuyer($id: uuid!) {
    delete_bandanas_buyers_by_pk(id: $id) {
      id
    }
  }
`

const BUYER_BY_ORIGINAL_ID = gql`
  query BuyerByOriginalId($original_buyer_id: String!) {
    bandanas_buyers(where: { original_buyer_id: { _eq: $original_buyer_id } }, limit: 1) {
      id
      first_name
      last_name
      original_buyer_id
    }
  }
`


export function useBuyersStore() {
  const { result, loading, error, refetch } = useQuery(BUYERS, null, {
    fetchPolicy: 'network-only',
  })

  const { mutate: createBuyerMut } = useMutation(CREATE_BUYER)
  const { mutate: updateBuyerMut } = useMutation(UPDATE_BUYER)
  const { mutate: deleteBuyerMut } = useMutation(DELETE_BUYER)

  const buyers = computed(() => result.value?.bandanas_buyers ?? [])

  async function createBuyer(data: {
    id?: string
    first_name: string
    last_name: string
    email?: string | null
    original_buyer_id?: string | null
  }) {
    const { data: result } = await createBuyerMut({ object: data })
    await refetch()
    return result?.insert_bandanas_buyers_one
  }

  async function updateBuyer(id: string, changes: {
    first_name?: string
    last_name?: string
    email?: string | null
    original_buyer_id?: string | null
  }) {
    const { data: result } = await updateBuyerMut({ id, changes })
    await refetch()
    return result?.update_bandanas_buyers_by_pk
  }

  async function deleteBuyer(id: string) {
    await deleteBuyerMut({ id })
    await refetch()
  }

  async function getBuyerByOriginalId(originalBuyerId: string) {
    const { data } = await apolloClient.query({
      query: BUYER_BY_ORIGINAL_ID,
      variables: { original_buyer_id: originalBuyerId },
      fetchPolicy: 'network-only',
    })
    return data?.bandanas_buyers?.[0] || null
  }

  return {
    buyers,
    loading,
    error,
    refetch,
    createBuyer,
    updateBuyer,
    deleteBuyer,
    getBuyerByOriginalId,
  }
}

