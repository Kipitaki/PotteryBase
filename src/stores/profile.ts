import { ref, computed, watch } from 'vue'
import { provideApolloClient, useQuery, useMutation } from '@vue/apollo-composable'
import gql from 'graphql-tag'
import { apolloClient } from 'boot/nhost'
import { nhost } from 'boot/nhost'

provideApolloClient(apolloClient)

/* ---------------------------- GraphQL ---------------------------- */
const GET_PROFILE = gql`
  query GetProfile($id: uuid!) {
    potterbase_profiles_by_pk(id: $id) {
      id
      display_name
      avatar_url
      unit_preference
      length_unit
      weight_unit
      created_at
      updated_at
    }
  }
`

const UPDATE_PROFILE = gql`
  mutation UpdateProfile($id: uuid!, $changes: potterbase_profiles_set_input!) {
    update_potterbase_profiles_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
      display_name
      avatar_url
      unit_preference
      length_unit
      weight_unit
      created_at
      updated_at
    }
  }
`

/* ---------------------------- Store ---------------------------- */
export function useProfileStore() {
  const profile = ref(null)
  const loading = ref(false)
  const error = ref(null)
  const user = ref(null)

  // Watch for auth state changes
  nhost.auth.onAuthStateChanged((event, session) => {
    user.value = session?.user || null
  })

  // Initialize user if already authenticated
  if (nhost.auth.isAuthenticated()) {
    user.value = nhost.auth.getUser()
  }

  const {
    result,
    loading: qLoading,
    error: qError,
    refetch,
  } = useQuery(GET_PROFILE, () => ({ id: user.value?.id }), {
    fetchPolicy: 'network-only',
    enabled: computed(() => !!user.value?.id),
  })

  watch(result, (val) => {
    profile.value = val?.potterbase_profiles_by_pk || null
  })
  watch(qError, (err) => {
    if (err) error.value = err
  })
  watch(qLoading, (val) => {
    loading.value = val
  })

  const { mutate: updateProfileMut } = useMutation(UPDATE_PROFILE)

  async function updateProfile(changes) {
    if (!user.value?.id) return null
    const { data } = await updateProfileMut({
      id: user.value.id,
      changes,
    })
    if (data?.update_potterbase_profiles_by_pk) {
      profile.value = data.update_potterbase_profiles_by_pk
    }
    return data?.update_potterbase_profiles_by_pk
  }

  /* ---------------------- Unit Helpers ---------------------- */
  const unitPreference = computed(() => profile.value?.unit_preference || 'imperial')
  const isMetric = computed(() => unitPreference.value === 'metric')

  // Display helpers (DB metric → user preference)
  function toLengthDisplay(cm) {
    if (cm == null || cm === '') return ''
    const value = parseFloat(cm)
    if (isNaN(value)) return ''
    return isMetric.value ? `${value.toFixed(1)} cm` : `${(value / 2.54).toFixed(2)} in`
  }

  function toWeightDisplay(g) {
    if (g == null || g === '') return ''
    const value = parseFloat(g)
    if (isNaN(value)) return ''
    return isMetric.value ? `${value.toFixed(0)} g` : `${(value / 453.592).toFixed(2)} lb`
  }

  // Input converters (user input → DB metric)
  function fromLengthInput(val) {
    if (val == null || val === '') return null
    const value = parseFloat(val)
    if (isNaN(value)) return null
    const cm = isMetric.value ? value : value * 2.54
    return Math.round(cm * 100) / 100 // round to 2 decimal places
  }

  function fromWeightInput(val) {
    if (val == null || val === '') return null
    const value = parseFloat(val)
    if (isNaN(value)) return null
    return isMetric.value ? value : value * 453.592 // always g
  }

  // Prep for editing (DB metric → user units for input fields)
  function toLengthInput(cm) {
    if (cm == null || cm === '') return ''
    const value = parseFloat(cm)
    if (isNaN(value)) return ''
    return isMetric.value ? value : Math.round((value / 2.54) * 100) / 100
  }

  function toWeightInput(g) {
    if (g == null || g === '') return ''
    const value = parseFloat(g)
    if (isNaN(value)) return ''
    return isMetric.value ? value : (value / 453.592).toFixed(2)
  }

  return {
    profile,
    loading,
    error,
    updateProfile,
    unitPreference,
    isMetric,
    toLengthDisplay,
    toWeightDisplay,
    fromLengthInput,
    fromWeightInput,
    toLengthInput,
    toWeightInput,
  }
}
