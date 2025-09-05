// stores/firings.ts
import { computed } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery } from '@vue/apollo-composable'
import { apolloClient } from 'boot/apollo'

provideApolloClient(apolloClient)

/* ------------------------------- */
/* GraphQL Query: recent firings   */
/* ------------------------------- */
const RECENT_CONES = gql`
  query RecentCones {
    potterbase_piece_firing(order_by: { date: desc }, limit: 20) {
      cone
      date
    }
  }
`

/* ------------------------------- */
/* Store                           */
/* ------------------------------- */
export function useFiringsStore() {
  const { result, loading, error, refetch } = useQuery(RECENT_CONES, null, {
    fetchPolicy: 'network-only',
  })

  // Deduplicate cones, keep most recent first
  const recentCones = computed(() => {
    const seen = new Set<string>()
    return (result.value?.potterbase_piece_firing || [])
      .map((f) => f.cone)
      .filter((c) => {
        if (!c || seen.has(c)) return false
        seen.add(c)
        return true
      })
      .map((c) => ({
        id: c,
        label: `Cone ${c}`,
        cone: c,
      }))
  })

  return {
    recentCones,
    loading,
    error,
    refetch,
  }
}
