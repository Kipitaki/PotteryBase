// src/stores/pieces.ts
import { ref, computed, watch } from 'vue'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery, useMutation } from '@vue/apollo-composable'
import { apolloClient } from 'boot/nhost'
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
      whatisit
      owner_id
      created_at
      updated_at
      visibility
      price
      is_for_sale
      in_stock

      # 👇 new
      profile {
        display_name
        avatar_url
      }

      piece_clays {
        id
        notes
        clay_body {
          id
          name
          brand
        }
      }

      piece_glazes(order_by: { application_order: asc }) {
        id
        layer_number
        application_method
        application_order
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
        weight_g
        width_cm
        stage
        piece_id
        location
        length_cm
        id
        height_cm
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

      piece_likes(order_by: { created_at: desc }) {
        id
        created_at
        profile {
          id
          display_name
          avatar_url
        }
      }

      piece_likes_aggregate {
        aggregate {
          count
        }
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
      whatisit
      visibility
      created_at
      updated_at
      price
      is_for_sale
      in_stock

      # 👇 new
      profile {
        display_name
        avatar_url
      }

      piece_clays {
        id
        notes
        clay_body {
          id
          name
          brand
        }
      }

      piece_glazes(order_by: { application_order: asc }) {
        id
        layer_number
        application_method
        application_order
        notes
        glaze {
          id
          name
          brand
          cone
          color
          code
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
        weight_g
        width_cm
        stage
        piece_id
        location
        length_cm
        id
        height_cm
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

      piece_likes(order_by: { created_at: desc }) {
        id
        created_at
        profile {
          id
          display_name
          avatar_url
        }
      }

      piece_likes_aggregate {
        aggregate {
          count
        }
      }
    }
  }
`

async function getPieceById(id: number) {
  // apolloClient is a Promise, so we need to await it first
  const client = await apolloClient
  const { data } = await client.query({
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
      whatisit
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

// Likes
const LIKE_PIECE = gql`
  mutation LikePiece($piece_id: Int!, $user_id: uuid!) {
    insert_potterbase_piece_likes_one(object: { piece_id: $piece_id, user_id: $user_id }) {
      id
      created_at
      profile {
        id
        display_name
        avatar_url
      }
    }
  }
`

const UNLIKE_PIECE = gql`
  mutation UnlikePiece($piece_id: Int!, $user_id: uuid!) {
    delete_potterbase_piece_likes(
      where: { piece_id: { _eq: $piece_id }, user_id: { _eq: $user_id } }
    ) {
      affected_rows
    }
  }
`

const GET_USER_LIKES = gql`
  query GetUserLikes($user_id: uuid!) {
    potterbase_piece_likes(where: { user_id: { _eq: $user_id } }, order_by: { created_at: desc }) {
      id
      created_at
      piece {
        id
        title
        visibility
        piece_images(where: { is_main: { _eq: true } }, limit: 1) {
          url
        }
      }
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
      application_order
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
      length_cm
      width_cm
      height_cm
      weight_g
      location
    }
  }
`
const UPDATESTAGE = gql`
  mutation UpdateStage($id: Int!, $changes: potterbase_piece_stage_history_set_input!) {
    update_potterbase_piece_stage_history_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
      stage
      date
      length_cm
      width_cm
      height_cm
      weight_g
      location
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
  })

  // watch(result, (val) => {
  //   //console.log('result', val)
  //   if (val?.potterbase_piece) {
  //     console.log('[Apollo Raw Result]', val.potterbase_piece)
  //   }
  // })
  watch(error, (err) => {
    if (err) console.error('[Apollo Error]', err)
  })

  // Mutations
  const { mutate: createPieceMut } = useMutation(CREATEPIECE)
  const { mutate: updatePieceMut } = useMutation(UPDATEPIECE)
  const { mutate: deletePieceMut } = useMutation(DELETEPIECE)

  const { mutate: likePieceMut } = useMutation(LIKE_PIECE)
  const { mutate: unlikePieceMut } = useMutation(UNLIKE_PIECE)

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
  const { mutate: updateStageMut } = useMutation(UPDATESTAGE)
  const { mutate: deleteStageMut } = useMutation(DELETESTAGE)

  const { mutate: addImageMut } = useMutation(ADDIMAGE)
  const { mutate: updateImageMut } = useMutation(UPDATEIMAGE)
  const { mutate: deleteImageMut } = useMutation(DELETEIMAGE)

  // Computed
  const all = computed(() => result.value?.potterbase_piece || [])
  const allArray = computed(() => result.value?.potterbase_piece || [])

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
  async function updateStage(id, changes) {
    const { data } = await updateStageMut({ id, changes })
    if (isAuthed.value) await refetch()
    return data?.update_potterbase_piece_stage_history_by_pk
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

  // Likes
  async function likePiece(pieceId) {
    const user = nhost.auth.getUser()
    if (!user?.id) throw new Error('User must be authenticated to like pieces')

    const { data } = await likePieceMut({
      piece_id: pieceId,
      user_id: user.id,
    })
    if (isAuthed.value) await refetch()
    return data?.insert_potterbase_piece_likes_one
  }

  async function unlikePiece(pieceId) {
    const user = nhost.auth.getUser()
    if (!user?.id) throw new Error('User must be authenticated to unlike pieces')

    const { data } = await unlikePieceMut({
      piece_id: pieceId,
      user_id: user.id,
    })
    if (isAuthed.value) await refetch()
    return data?.delete_potterbase_piece_likes
  }

  async function toggleLike(pieceId) {
    const user = nhost.auth.getUser()
    if (!user?.id) throw new Error('User must be authenticated to like pieces')

    // Find the piece in current data
    const piecesData = result.value?.potterbase_piece || []
    const piece = piecesData.find((p) => p.id === pieceId)
    if (!piece) throw new Error('Piece not found')

    // Check if user has already liked this piece
    const userLike = piece.piece_likes?.find((like) => like.profile?.id === user.id)

    if (userLike) {
      return await unlikePiece(pieceId)
    } else {
      return await likePiece(pieceId)
    }
  }

  function isLikedByUser(pieceId) {
    const user = nhost.auth.getUser()
    if (!user?.id) return false

    const piecesData = result.value?.potterbase_piece || []
    const piece = piecesData.find((p) => p.id === pieceId)
    if (!piece) return false

    return piece.piece_likes?.some((like) => like.profile?.id === user.id) || false
  }

  function getLikeCount(pieceId) {
    const piecesData = result.value?.potterbase_piece || []
    const piece = piecesData.find((p) => p.id === pieceId)
    return piece?.piece_likes_aggregate?.aggregate?.count || 0
  }

  function getLikeTooltipText(pieceId) {
    const piecesData = result.value?.potterbase_piece || []
    const piece = piecesData.find((p) => p.id === pieceId)
    const likes = piece?.piece_likes || []

    if (likes.length === 0) return 'No likes yet'

    const names = likes.map((like) => like.profile?.display_name || 'Unknown').filter(Boolean)

    if (names.length <= 3) {
      return `Liked by ${names.join(', ')}`
    }

    const shown = names.slice(0, 2)
    const remaining = names.length - 2
    return `Liked by ${shown.join(', ')} and ${remaining} others`
  }

  async function getUserLikes(userId) {
    const { data } = await apolloClient.query({
      query: GET_USER_LIKES,
      variables: { user_id: userId },
      fetchPolicy: 'network-only',
    })
    return data?.potterbase_piece_likes || []
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
    updateStage,
    deleteStage,

    addImage,
    updateImage,
    deleteImage,

    // Likes
    likePiece,
    unlikePiece,
    toggleLike,
    isLikedByUser,
    getLikeCount,
    getLikeTooltipText,
    getUserLikes,
  }
}
