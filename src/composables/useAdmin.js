import { ref, computed, watch } from 'vue'
import { useUserData } from '@nhost/vue'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery } from '@vue/apollo-composable'
import { apolloClient } from 'boot/apollo'

provideApolloClient(apolloClient)

const GET_USER_ROLES = gql`
  query GetUserRoles($userId: uuid!) {
    authUserRoles(where: { userId: { _eq: $userId } }) {
      role
    }
  }
`

export function useAdmin() {
  const user = useUserData()
  const isAdmin = ref(false)
  const loading = ref(false)

  const userId = computed(() => user.value?.id)

  const { result, loading: queryLoading } = useQuery(
    GET_USER_ROLES,
    () => ({ userId: userId.value }),
    computed(() => ({
      enabled: !!userId.value,
      fetchPolicy: 'network-only',
    })),
  )

  watch(queryLoading, (val) => {
    loading.value = val
  })

  watch(result, (val) => {
    if (val?.authUserRoles) {
      const roles = val.authUserRoles.map((ur) => ur.role?.toLowerCase().trim())
      isAdmin.value = roles.includes('admin')
      console.log('[useAdmin] User roles:', roles, 'isAdmin:', isAdmin.value)
    } else {
      isAdmin.value = false
      console.log('[useAdmin] No roles found, setting isAdmin to false')
    }
  })

  watch(userId, (newId) => {
    isAdmin.value = false
    console.log('[useAdmin] User ID changed:', newId)
  })

  // Also check on mount if user is already authenticated
  if (userId.value) {
    // Query will run automatically due to enabled computed
  }

  return {
    isAdmin: computed(() => isAdmin.value),
    loading: computed(() => loading.value),
  }
}
