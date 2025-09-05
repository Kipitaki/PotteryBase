import { computed } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery, useMutation } from '@vue/apollo-composable'
import { apolloClient } from 'boot/nhost'
import { nhost } from 'boot/nhost'

provideApolloClient(apolloClient)

/* -------- Queries -------- */
const CLAYS = gql`
  query AllClays {
    potterbase_clay_body(order_by: { name: asc }) {
      id
      name
      brand
    }
  }
`

const RECENT_CLAYS = gql`
  query RecentClays {
    potterbase_piece_clay(order_by: { id: desc }, limit: 5) {
      id
      clay_body {
        id
        name
        brand
      }
    }
  }
`

/* -------- Mutations -------- */
const CREATE_CLAYBODY = gql`
  mutation CreateClayBody($object: potterbase_clay_body_insert_input!) {
    insert_potterbase_clay_body_one(object: $object) {
      id
      name
      brand
    }
  }
`

export function useClaysStore() {
  const isAuthed = computed(() => nhost.auth.isAuthenticated())

  // master list
  const { result, loading, error, refetch } = useQuery(CLAYS, null, {
    fetchPolicy: 'network-only',
    enabled: isAuthed,
  })

  // 5 most recently used (from piece_clay)
  const {
    result: recentResult,
    loading: recentLoading,
    error: recentError,
    refetch: refetchRecent,
  } = useQuery(RECENT_CLAYS, null, {
    fetchPolicy: 'network-only',
    enabled: isAuthed,
  })

  const { mutate: createClayBodyMut } = useMutation(CREATE_CLAYBODY)

  /* -------- Computed -------- */
  const all = computed(() => result.value?.potterbase_clay_body ?? [])

  const options = computed(() =>
    all.value.map((c: any) => ({
      id: c.id,
      label: `${c.name}${c.brand ? ' (' + c.brand + ')' : ''}`,
    })),
  )

  const recent = computed(() =>
    (recentResult.value?.potterbase_piece_clay ?? []).map((pc: any) => ({
      id: pc.clay_body.id,
      name: pc.clay_body.name,
      brand: pc.clay_body.brand,
    })),
  )

  /* -------- Actions -------- */
  async function createClayBody(object: { name: string; brand?: string | null }) {
    const { data } = await createClayBodyMut({ object })
    await Promise.all([refetch(), refetchRecent()])
    return data?.insert_potterbase_clay_body_one
  }

  return {
    // data
    all,
    options,
    recent,

    // status
    loading,
    error,
    recentLoading,
    recentError,

    // actions
    refetch,
    refetchRecent,
    createClayBody,
  }
}
