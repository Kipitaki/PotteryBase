import { computed } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery, useMutation } from '@vue/apollo-composable'
import { apolloClient } from 'boot/apollo'

provideApolloClient(apolloClient)

/* -------- Queries -------- */
const GLAZES = gql`
  query Glazes {
    potterbase_glaze(order_by: { name: asc }) {
      brand
      code
      color
      cone
      display_name
      finish
      name
      notes
      id
      series
    }
  }
`
const RECENT_GLAZES = gql`
  query RecentGlazes {
    potterbase_glaze(order_by: { id: desc }, limit: 5) {
      brand
      code
      color
      cone
      display_name
      finish
      name
      notes
      id
      series
    }
  }
`

/* ---- Mutations ---- */
const CREATE_GLAZE = gql`
  mutation CreateGlaze($object: potterbase_glaze_insert_input!) {
    insert_potterbase_glaze_one(object: $object) {
      brand
      code
      color
      cone
      display_name
      finish
      name
      notes
      id
      series
    }
  }
`
export function useGlazesStore() {
  const { result: allResult, refetch: refetchAll } = useQuery(GLAZES)
  const { result: recentResult, refetch: refetchRecent } = useQuery(RECENT_GLAZES)
  const { mutate: createGlazeMutation } = useMutation(CREATE_GLAZE)

  const options = computed(() =>
    (allResult.value?.potterbase_glaze || []).map((g: any) => ({
      id: g.id,
      name: g.name, // <-- keep this for chips
      label: `${g.name}${g.brand ? ' (' + g.brand + ')' : ''} – ${g.color || ''} [Cone ${g.cone || ''}]`,
    })),
  )

  const recent = computed(() => recentResult.value?.potterbase_glaze || [])

  async function createGlaze(obj: any) {
    const { data } = await createGlazeMutation({ object: obj })
    return data?.insert_potterbase_glaze_one
  }

  return {
    options,
    recent,
    refetch: refetchAll,
    refetchRecent,
    createGlaze,
  }
}
