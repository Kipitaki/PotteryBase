import { computed } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery, useMutation } from '@vue/apollo-composable'
import { apolloClient } from 'boot/apollo'

provideApolloClient(apolloClient)

const EVENTS = gql`
  query Events {
    bandanas_events(order_by: { year: desc, name: asc }) {
      id
      name
      year
      price_single
      price_multi
      bandana_cost
      freight
      fee_tax_transaction_fees
      freight_out
      total_qty
      active
      image_url
      created_at
      updated_at
    }
  }
`

const EVENT_BY_ID = gql`
  query EventById($id: uuid!) {
    bandanas_events_by_pk(id: $id) {
      id
      name
      year
      price_single
      price_multi
      bandana_cost
      freight
      fee_tax_transaction_fees
      freight_out
      total_qty
      active
      image_url
      created_at
      updated_at
    }
  }
`

const CREATE_EVENT = gql`
  mutation CreateEvent($object: bandanas_events_insert_input!) {
    insert_bandanas_events_one(object: $object) {
      id
      name
      year
      price_single
      price_multi
      bandana_cost
      freight
      fee_tax_transaction_fees
      freight_out
      total_qty
      active
      image_url
      created_at
      updated_at
    }
  }
`

const UPDATE_EVENT = gql`
  mutation UpdateEvent($id: uuid!, $changes: bandanas_events_set_input!) {
    update_bandanas_events_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
      name
      year
      price_single
      price_multi
      bandana_cost
      freight
      fee_tax_transaction_fees
      freight_out
      total_qty
      active
      updated_at
    }
  }
`

const DELETE_EVENT = gql`
  mutation DeleteEvent($id: uuid!) {
    delete_bandanas_events_by_pk(id: $id) {
      id
    }
  }
`

const EVENT_BY_NAME = gql`
  query EventByName($name: String!) {
    bandanas_events(where: { name: { _eq: $name } }, limit: 1) {
      id
      name
      year
    }
  }
`

export function useEventsStore() {
  const { result, loading, error, refetch } = useQuery(EVENTS, null, {
    fetchPolicy: 'network-only',
  })

  const { mutate: createEventMut } = useMutation(CREATE_EVENT)
  const { mutate: updateEventMut } = useMutation(UPDATE_EVENT)
  const { mutate: deleteEventMut } = useMutation(DELETE_EVENT)

  const events = computed(() => result.value?.bandanas_events ?? [])

  async function createEvent(data: {
    name: string
    year: number
    price_single: number
    price_multi: number
    bandana_cost?: number | null
    freight?: number | null
    fee_tax_transaction_fees?: number | null
    freight_out?: number | null
    total_qty?: number | null
    active?: boolean
    image_url?: string | null
  }) {
    const { data: result } = await createEventMut({ object: data })
    await refetch()
    return result?.insert_bandanas_events_one
  }

  async function updateEvent(id: string, changes: {
    name?: string
    year?: number
    price_single?: number
    price_multi?: number
    bandana_cost?: number | null
    freight?: number | null
    fee_tax_transaction_fees?: number | null
    freight_out?: number | null
    total_qty?: number | null
    active?: boolean
    image_url?: string | null
  }) {
    const { data: result } = await updateEventMut({ id, changes })
    await refetch()
    return result?.update_bandanas_events_by_pk
  }

  async function deleteEvent(id: string) {
    await deleteEventMut({ id })
    await refetch()
  }

  async function getEventByName(name: string) {
    const { data } = await apolloClient.query({
      query: EVENT_BY_NAME,
      variables: { name },
      fetchPolicy: 'network-only',
    })
    return data?.bandanas_events?.[0] || null
  }

  return {
    events,
    loading,
    error,
    refetch,
    createEvent,
    updateEvent,
    deleteEvent,
    getEventByName,
  }
}

