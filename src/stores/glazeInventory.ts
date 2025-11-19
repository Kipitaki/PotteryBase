import { computed, ref, watch } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useMutation, useQuery } from '@vue/apollo-composable'
import { nhost } from 'boot/nhost'
import { apolloClient } from 'boot/apollo'

provideApolloClient(apolloClient)

const CLASS_GLAZES = gql`
  query ClassGlazes {
    potterbase_class_glaze(order_by: { glaze: { name: asc } }) {
      id
      quantity
      unit
      location
      status
      notes
      updated_at
      glaze {
        id
        name
        brand
        color
        cone
        display_name
        finish
      }
    }
  }
`

const MY_GLAZES = gql`
  query MyGlazes($profileId: uuid!) {
    potterbase_profile_glaze(
      where: { profile_id: { _eq: $profileId } }
      order_by: { glaze: { name: asc } }
    ) {
      id
      quantity
      unit
      location
      status
      notes
      updated_at
      glaze {
        id
        name
        brand
        color
        cone
        display_name
        finish
        piece_glazes(
          where: { piece: { owner_id: { _eq: $profileId } } }
          order_by: { piece_id: asc }
        ) {
          piece {
            id
            title
            owner_id
          }
        }
      }
    }
  }
`

const UPSERT_PROFILE_GLAZE = gql`
  mutation UpsertProfileGlaze($object: potterbase_profile_glaze_insert_input!) {
    insert_potterbase_profile_glaze_one(
      object: $object
      on_conflict: {
        constraint: profile_glaze_profile_id_glaze_id_key
        update_columns: [quantity, unit, location, status, notes]
      }
    ) {
      id
    }
  }
`

const UPDATE_PROFILE_GLAZE = gql`
  mutation UpdateProfileGlaze($id: Int!, $changes: potterbase_profile_glaze_set_input!) {
    update_potterbase_profile_glaze_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
    }
  }
`

const DELETE_PROFILE_GLAZE = gql`
  mutation DeleteProfileGlaze($id: Int!) {
    delete_potterbase_profile_glaze_by_pk(id: $id) {
      id
    }
  }
`

export function useGlazeInventoryStore() {
  const classQuery = useQuery(CLASS_GLAZES)

  const profileId = ref<string | null>(nhost.auth.getUser()?.id ?? null)

  nhost.auth.onAuthStateChanged(() => {
    profileId.value = nhost.auth.getUser()?.id ?? null
  })

  const myQuery = useQuery(
    MY_GLAZES,
    computed(() => ({
      profileId: profileId.value ?? '00000000-0000-0000-0000-000000000000',
    })),
    computed(() => ({
      enabled: Boolean(profileId.value),
      fetchPolicy: 'network-only',
    })),
  )

  watch(myQuery.error, (err) => {
    if (err) {
      console.error('[GlazeInventory] Query error:', err)
    }
  })

  const { mutate: upsertMut } = useMutation(UPSERT_PROFILE_GLAZE)
  const { mutate: updateMut } = useMutation(UPDATE_PROFILE_GLAZE)
  const { mutate: deleteMut } = useMutation(DELETE_PROFILE_GLAZE)

  const classGlazes = computed(() => classQuery.result.value?.potterbase_class_glaze ?? [])
  const myGlazes = computed(() =>
    profileId.value ? (myQuery.result.value?.potterbase_profile_glaze ?? []) : [],
  )
  const isLoading = computed(() => classQuery.loading.value || myQuery.loading.value)

  async function refetch() {
    try {
      await Promise.all([
        classQuery.refetch(),
        profileId.value
          ? myQuery.refetch({ profileId: profileId.value }).catch((err) => {
              console.error('[GlazeInventory] Refetch error:', err)
              throw err
            })
          : Promise.resolve(),
      ])
    } catch (error) {
      console.error('[GlazeInventory] Refetch failed:', error)
      throw error
    }
  }

  async function upsertMyGlaze(payload: {
    glaze_id: number
    quantity?: number | null
    unit?: string | null
    location?: string | null
    status?: string | null
    notes?: string | null
  }) {
    if (!profileId.value) {
      throw new Error('User must be signed in to modify glaze inventory')
    }
    await upsertMut({
      object: {
        ...payload,
        profile_id: profileId.value,
      },
    })
    await refetch()
  }

  async function updateMyGlaze(id: number, changes: Record<string, unknown>) {
    await updateMut({ id, changes })
    await refetch()
  }

  async function removeMyGlaze(id: number) {
    await deleteMut({ id })
    await refetch()
  }

  async function bulkImportFromCSV(
    csvData: Array<Record<string, string>>,
    glazeCodeMap: Map<string, number>,
  ) {
    if (!profileId.value) {
      throw new Error('User must be signed in to import glazes')
    }

    const results = {
      success: 0,
      failed: 0,
      errors: [] as Array<{ code: string; error: string }>,
    }

    for (const row of csvData) {
      const code = row.code?.trim()
      if (!code) {
        results.failed++
        results.errors.push({ code: 'N/A', error: 'Missing code column' })
        continue
      }

      const glazeId = glazeCodeMap.get(code)
      if (!glazeId) {
        results.failed++
        results.errors.push({ code, error: `Glaze with code "${code}" not found` })
        continue
      }

      try {
        await upsertMut({
          object: {
            glaze_id: glazeId,
            profile_id: profileId.value,
            quantity: row.quantity ? parseFloat(row.quantity) : null,
            unit: row.unit?.trim() || null,
            location: row.location?.trim() || null,
            status: row.status?.trim() || 'available',
            notes: row.notes?.trim() || null,
          },
        })
        results.success++
      } catch (error) {
        results.failed++
        results.errors.push({
          code,
          error: error instanceof Error ? error.message : 'Unknown error',
        })
      }
    }

    await refetch()
    return results
  }

  return {
    classGlazes,
    myGlazes,
    isLoading,
    profileId,
    refetch,
    upsertMyGlaze,
    updateMyGlaze,
    removeMyGlaze,
    bulkImportFromCSV,
  }
}
