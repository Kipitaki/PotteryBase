// src/stores/pieces.ts
import { ref, computed, watch } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery, useMutation } from '@vue/apollo-composable'
import { apolloClient } from 'boot/apollo'
import { nhost } from 'boot/nhost'

provideApolloClient(apolloClient)

/* ---------------------------------- */
/* GraphQL Queries                     */
/* ---------------------------------- */

const PIECES = gql`
  query Pieces {
    potterbase_piece(order_by: { created_at: desc }) {
      id
      title
      notes
      owner_id
      created_at
      updated_at
      visibility

      piece_clays {
        id
        notes
        clay_body {
          id
          name
          brand
        }
      }

      piece_glazes(order_by: { layer_number: asc }) {
        id
        layer_number
        application_method
        notes
        glaze {
          id
          name
          brand
          cone
          color
        }
      }

      piece_firings(order_by: { date: asc }) {
        id
        cone
        temperature_f
        kiln_type
        kiln_location
        load_name
        date
      }

      piece_stage_histories(order_by: { date: asc }) {
        id
        stage
        date
      }

      piece_images(order_by: { uploaded_at: desc }) {
        id
        url
        file_id
        stage
        is_main
        uploaded_at
        taken_at
        notes
      }
    }
  }
`
const PIECE_BY_ID = gql`
  query PieceById($id: Int!) {
    potterbase_piece_by_pk(id: $id) {
      id
      title
      notes
      visibility
      created_at
      updated_at

      piece_clays {
        id
        notes
        clay_body {
          id
          name
          brand
        }
      }

      piece_glazes(order_by: { layer_number: asc }) {
        id
        layer_number
        application_method
        notes
        glaze {
          id
          name
          brand
          cone
          color
        }
      }

      piece_firings(order_by: { date: asc }) {
        id
        cone
        temperature_f
        kiln_type
        kiln_location
        load_name
        date
      }

      piece_stage_histories(order_by: { date: asc }) {
        id
        stage
        date
      }

      piece_images(order_by: { uploaded_at: desc }) {
        id
        url
        file_id
        stage
        is_main
        uploaded_at
        taken_at
        notes
      }
    }
  }
`

async function getPieceById(id: number) {
  const { data } = await apolloClient.query({
    query: PIECE_BY_ID,
    variables: { id },
    fetchPolicy: 'network-only',
  })
  return data?.potterbase_piece_by_pk
}

/* ---------------------------------- */
/* GraphQL Mutations                   */
/* ---------------------------------- */

// Pieces
const CREATEPIECE = gql`
  mutation CreatePiece($object: potterbase_piece_insert_input!) {
    insert_potterbase_piece_one(object: $object) {
      id
      title
      notes
    }
  }
`
const UPDATEPIECE = gql`
  mutation UpdatePiece($id: Int!, $changes: potterbase_piece_set_input!) {
    update_potterbase_piece_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
      title
    }
  }
`
const DELETEPIECE = gql`
  mutation DeletePiece($id: Int!) {
    delete_potterbase_piece_by_pk(id: $id) {
      id
    }
  }
`

// Clays
const CREATECLAYBODY = gql`
  mutation CreateClayBody($object: potterbase_clay_body_insert_input!) {
    insert_potterbase_clay_body_one(object: $object) {
      id
      name
      brand
    }
  }
`
const DELETECLAYBODY = gql`
  mutation DeleteClayBody($id: Int!) {
    delete_potterbase_clay_body_by_pk(id: $id) {
      id
    }
  }
`
const ADDCLAYTOPIECE = gql`
  mutation AddClayToPiece($object: potterbase_piece_clay_insert_input!) {
    insert_potterbase_piece_clay_one(object: $object) {
      id
      piece_id
      clay_body_id
      notes
    }
  }
`
const UPDATEPIECECLAYROW = gql`
  mutation UpdatePieceClayRow($id: Int!, $changes: potterbase_piece_clay_set_input!) {
    update_potterbase_piece_clay_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
    }
  }
`
const DELETEPIECECLAYROW = gql`
  mutation DeletePieceClayRow($id: Int!) {
    delete_potterbase_piece_clay_by_pk(id: $id) {
      id
    }
  }
`

// Glazes
const CREATEGLAZE = gql`
  mutation CreateGlaze($object: potterbase_glaze_insert_input!) {
    insert_potterbase_glaze_one(object: $object) {
      id
      name
      brand
    }
  }
`
const ADDGLAZETOPIECE = gql`
  mutation AddGlazeToPiece($object: potterbase_piece_glaze_insert_input!) {
    insert_potterbase_piece_glaze_one(object: $object) {
      id
      piece_id
      glaze_id
      notes
    }
  }
`
const UPDATEPIECEGLAZE = gql`
  mutation UpdatePieceGlaze($id: Int!, $changes: potterbase_piece_glaze_set_input!) {
    update_potterbase_piece_glaze_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
    }
  }
`
const DELETEPIECEGLAZE = gql`
  mutation DeletePieceGlaze($id: Int!) {
    delete_potterbase_piece_glaze_by_pk(id: $id) {
      id
    }
  }
`

// Firings
const ADDFIRING = gql`
  mutation AddFiring($object: potterbase_piece_firing_insert_input!) {
    insert_potterbase_piece_firing_one(object: $object) {
      id
      piece_id
      cone
    }
  }
`
const UPDATEFIRING = gql`
  mutation UpdateFiring($id: Int!, $changes: potterbase_piece_firing_set_input!) {
    update_potterbase_piece_firing_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
    }
  }
`
const DELETEFIRING = gql`
  mutation DeleteFiring($id: Int!) {
    delete_potterbase_piece_firing_by_pk(id: $id) {
      id
    }
  }
`

// Stages
const ADDSTAGE = gql`
  mutation AddStage($object: potterbase_piece_stage_history_insert_input!) {
    insert_potterbase_piece_stage_history_one(object: $object) {
      id
      stage
      date
    }
  }
`
const DELETESTAGE = gql`
  mutation DeleteStage($id: Int!) {
    delete_potterbase_piece_stage_history_by_pk(id: $id) {
      id
    }
  }
`

// Images
const ADDIMAGE = gql`
  mutation AddImage($object: potterbase_piece_image_insert_input!) {
    insert_potterbase_piece_image_one(object: $object) {
      id
      url
      stage
      is_main
      uploaded_at
    }
  }
`
const UPDATEIMAGE = gql`
  mutation UpdateImage($id: uuid!, $changes: potterbase_piece_image_set_input!) {
    update_potterbase_piece_image_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
    }
  }
`
const DELETEIMAGE = gql`
  mutation DeleteImage($id: uuid!) {
    delete_potterbase_piece_image_by_pk(id: $id) {
      id
    }
  }
`

/* ---------------------------------- */
/* Store                              */
/* ---------------------------------- */

export function usePiecesStore() {
  const pieces = ref([])

  const isAuthed = computed(() => nhost.auth.isAuthenticated())

  const { result, loading, error, refetch } = useQuery(PIECES, null, {
    fetchPolicy: 'network-only',
    enabled: isAuthed,
  })

  watch(result, (val) => {
    if (val?.potterbase_piece) {
      // console.log('[Apollo Raw Result]', val.potterbase_piece)
    }
  })
  watch(error, (err) => {
    if (err) console.error('[Apollo Error]', err)
  })

  // Mutations
  const { mutate: createPieceMut } = useMutation(CREATEPIECE)
  const { mutate: updatePieceMut } = useMutation(UPDATEPIECE)
  const { mutate: deletePieceMut } = useMutation(DELETEPIECE)

  const { mutate: createClayMut } = useMutation(CREATECLAYBODY)
  const { mutate: deleteClayMut } = useMutation(DELETECLAYBODY)
  const { mutate: addClayToPieceMut } = useMutation(ADDCLAYTOPIECE)
  const { mutate: updatePieceClayRowMut } = useMutation(UPDATEPIECECLAYROW)
  const { mutate: deletePieceClayRowMut } = useMutation(DELETEPIECECLAYROW)

  const { mutate: createGlazeMut } = useMutation(CREATEGLAZE)
  const { mutate: addGlazeToPieceMut } = useMutation(ADDGLAZETOPIECE)
  const { mutate: updatePieceGlazeMut } = useMutation(UPDATEPIECEGLAZE)
  const { mutate: deletePieceGlazeMut } = useMutation(DELETEPIECEGLAZE)

  const { mutate: addFiringMut } = useMutation(ADDFIRING)
  const { mutate: updateFiringMut } = useMutation(UPDATEFIRING)
  const { mutate: deleteFiringMut } = useMutation(DELETEFIRING)

  const { mutate: addStageMut } = useMutation(ADDSTAGE)
  const { mutate: deleteStageMut } = useMutation(DELETESTAGE)

  const { mutate: addImageMut } = useMutation(ADDIMAGE)
  const { mutate: updateImageMut } = useMutation(UPDATEIMAGE)
  const { mutate: deleteImageMut } = useMutation(DELETEIMAGE)

  // Computed
  const all = computed(() => result.value?.potterbase_piece ?? [])
  const allArray = computed(() => all.value)

  /* ------------ Actions ------------ */

  // Pieces
  async function createPiece(object) {
    const { data } = await createPieceMut({ object })
    await refetch()
    return data?.insert_potterbase_piece_one
  }
  async function updatePiece(id, changes) {
    const { data } = await updatePieceMut({ id, changes })
    await refetch()
    return data?.update_potterbase_piece_by_pk
  }
  async function deletePiece(id) {
    const { data } = await deletePieceMut({ id })
    if (isAuthed.value) await refetch()
    return data?.delete_potterbase_piece_by_pk
  }

  // Clay
  async function createClayBody(object) {
    const { data } = await createClayMut({ object })
    if (isAuthed.value) await refetch()
    return data?.insert_potterbase_clay_body_one
  }
  async function deleteClayBody(id) {
    const { data } = await deleteClayMut({ id })
    if (isAuthed.value) await refetch()
    return data?.delete_potterbase_clay_body_by_pk
  }
  async function addClayToPiece(object) {
    const { data } = await addClayToPieceMut({ object })
    if (isAuthed.value) await refetch()
    return data?.insert_potterbase_piece_clay_one
  }
  async function updatePieceClayRow(id, changes) {
    const { data } = await updatePieceClayRowMut({ id, changes })
    if (isAuthed.value) await refetch()
    return data?.update_potterbase_piece_clay_by_pk
  }
  async function deletePieceClayRow(id) {
    const { data } = await deletePieceClayRowMut({ id })
    if (isAuthed.value) await refetch()
    return data?.delete_potterbase_piece_clay_by_pk
  }

  // Glazes
  async function createGlaze(object) {
    const { data } = await createGlazeMut({ object })
    return data?.insert_potterbase_glaze_one
  }
  async function addGlazeToPiece(object) {
    const { data } = await addGlazeToPieceMut({ object })
    if (isAuthed.value) await refetch()
    return data?.insert_potterbase_piece_glaze_one
  }
  async function updatePieceGlaze(id, changes) {
    const { data } = await updatePieceGlazeMut({ id, changes })
    if (isAuthed.value) await refetch()
    return data?.update_potterbase_piece_glaze_by_pk
  }
  async function deletePieceGlaze(id) {
    const { data } = await deletePieceGlazeMut({ id })
    if (isAuthed.value) await refetch()
    return data?.delete_potterbase_piece_glaze_by_pk
  }

  // Firings
  async function addFiring(object) {
    const { data } = await addFiringMut({ object })
    if (isAuthed.value) await refetch()
    return data?.insert_potterbase_piece_firing_one
  }
  async function updateFiring(id, changes) {
    const { data } = await updateFiringMut({ id, changes })
    if (isAuthed.value) await refetch()
    return data?.update_potterbase_piece_firing_by_pk
  }
  async function deleteFiring(id) {
    const { data } = await deleteFiringMut({ id })
    if (isAuthed.value) await refetch()
    return data?.delete_potterbase_piece_firing_by_pk
  }

  // Stages
  async function addStage(object) {
    const { data } = await addStageMut({ object })
    if (isAuthed.value) await refetch()
    return data?.insert_potterbase_piece_stage_history_one
  }
  async function deleteStage(id) {
    const { data } = await deleteStageMut({ id })
    if (isAuthed.value) await refetch()
    return data?.delete_potterbase_piece_stage_history_by_pk
  }

  // Images
  async function addImage(object) {
    const { data } = await addImageMut({ object })
    if (isAuthed.value) await refetch()
    return data?.insert_potterbase_piece_image_one
  }
  async function updateImage(id, changes) {
    const { data } = await updateImageMut({ id, changes })
    if (isAuthed.value) await refetch()
    return data?.update_potterbase_piece_image_by_pk
  }
  async function deleteImage(id) {
    const { data } = await deleteImageMut({ id })
    if (isAuthed.value) await refetch()
    return data?.delete_potterbase_piece_image_by_pk
  }

  return {
    all,
    allArray,
    loading,
    error,
    refetch,
    getPieceById, // ✅ new
    createPiece,
    updatePiece,
    deletePiece,

    createClayBody,
    deleteClayBody,
    addClayToPiece,
    updatePieceClayRow,
    deletePieceClayRow,

    createGlaze,
    addGlazeToPiece,
    updatePieceGlaze,
    deletePieceGlaze,

    addFiring,
    updateFiring,
    deleteFiring,

    addStage,
    deleteStage,

    addImage,
    updateImage,
    deleteImage,
  }
}
