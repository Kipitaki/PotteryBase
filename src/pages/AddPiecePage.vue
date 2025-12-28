<template>
  <q-page padding class="bg-grey-1">
    <q-form @submit.prevent="onSave">
      <!-- Header -->
      <piece-header-bar
        v-model:title="form.title"
        v-model:share="form.share"
        :latest="latestStage"
        :stage-label-map="stageLabelMap"
        class="q-mb-xs"
      />

      <!-- What is it & Notes -->
      <div class="row q-col-gutter-md items-start q-mb-xs">
        <!-- LEFT: What is it -->
        <div class="col-12 col-md-4">
          <div class="row items-center q-gutter-xs q-mb-xs">
            <span class="text-caption text-grey-7">What is it?</span>

            <q-chip
              v-for="option in recentWhatisitOptions"
              :key="option"
              dense
              clickable
              outline
              color="grey-6"
              size="sm"
              @click="form.whatisit = option"
            >
              {{ option }}
            </q-chip>
          </div>
          <q-input
            v-model="form.whatisit"
            dense
            hide-bottom-space
            placeholder="e.g., mug, bowl, vase..."
          />
        </div>

        <!-- RIGHT: Notes -->
        <div class="col-12 col-md-8">
          <div class="row items-center q-gutter-xs q-mb-xs">
            <span class="text-caption text-grey-7">Notes</span>
          </div>
          <q-input
            v-model="form.notes"
            dense
            hide-bottom-space
            placeholder="Add notes about this piece..."
          />
        </div>
      </div>

      <!-- Photos -->
      <photo-gallery-editor
        v-model="form.photos"
        :piece-id="currentPieceId"
        :is-hydrating="isHydrating"
        class="q-mb-md"
      />

      <div class="row q-col-gutter-md">
        <!-- LEFT: Stages -->
        <div class="col-12 col-md-4">
          <stage-checklist :stages="STAGES" v-model="stageHistories" :piece-id="piece?.id" />
        </div>

        <!-- RIGHT: Clay / Glaze / Firing / Notes -->
        <div class="col-12 col-md-8">
          <clay-picker
            v-model="form.clays"
            :piece-id="currentPieceId"
            :is-hydrating="isHydrating"
          />
          <glaze-rows-editor
            v-model="form.glazes"
            :piece-id="currentPieceId"
            :is-hydrating="isHydrating"
          />
          <firing-rows-editor
            v-model="form.firings"
            :piece-id="currentPieceId"
            :is-hydrating="isHydrating"
          />
        </div>
      </div>

      <!-- For Sale Section -->
      <q-card class="q-mt-md">
        <q-card-section>
          <div class="text-h6 q-mb-md">For Sale</div>
          <div class="row q-col-gutter-md">
            <div class="col-12">
              <q-toggle
                v-model="form.is_for_sale"
                label="Offer this piece for sale"
                color="primary"
              />
            </div>
            <div v-if="form.is_for_sale" class="col-12 col-md-6">
              <q-input
                v-model.number="form.price"
                type="number"
                label="Price ($)"
                prefix="$"
                outlined
                :rules="[
                  (val) =>
                    val === null ||
                    val === '' ||
                    (val >= 0 && val <= 10000) ||
                    'Price must be between $0 and $10,000',
                ]"
                hint="Enter the price in dollars"
              />
            </div>
            <div v-if="form.is_for_sale" class="col-12 col-md-6">
              <q-toggle
                v-model="form.in_stock"
                label="In stock"
                color="positive"
                :disable="!form.is_for_sale"
              />
              <div class="text-caption text-grey-6 q-mt-xs">
                Uncheck if this piece is sold or unavailable
              </div>
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- Actions -->
      <div class="row items-center justify-between q-gutter-sm q-mt-md q-mb-xl">
        <div>
          <q-badge v-if="dirty" color="warning" outline class="q-mr-sm">Unsaved changes</q-badge>
          <span v-else-if="isEdit" class="text-caption text-grey-7">Editing existing piece</span>
        </div>
        <div>
          <q-btn flat dense icon="home" label="Home" class="q-mr-sm" :to="{ name: 'home' }" />
          <q-btn
            flat
            dense
            icon="inventory_2"
            label="Shelf"
            class="q-mr-sm"
            :to="{ name: 'shelf' }"
          />
          <q-btn flat dense label="Cancel" class="q-mr-sm" @click="handleCancel" />
          <q-btn color="primary" label="Done" type="submit" />
        </div>
      </div>
    </q-form>
  </q-page>
</template>

<script setup>
import { reactive, computed, onMounted, ref, watch, nextTick, onBeforeUnmount } from 'vue'
import { onBeforeRouteLeave, useRouter, useRoute } from 'vue-router'
import { useQuasar } from 'quasar'

import PieceHeaderBar from 'src/components/PieceHeaderBar.vue'
import PhotoGalleryEditor from 'src/components/PhotoGalleryEditor.vue'
import StageChecklist from 'src/components/StageChecklist.vue'
import ClayPicker from 'src/components/ClayPicker.vue'
import GlazeRowsEditor from 'src/components/GlazeRowsEditor.vue'
import FiringRowsEditor from 'src/components/FiringRowsEditor.vue'
//import SectionCard from 'src/components/SectionCard.vue'
import { useNameGeneratorStore } from 'src/stores/nameGenerator'
import { usePiecesStore } from 'src/stores/pieces'
import { useProfileStore } from 'src/stores/profile'

const piecesStore = usePiecesStore()
const nameGen = useNameGeneratorStore()
const profileStore = useProfileStore()
const $q = useQuasar()

/* ---------- Stages ---------- */
const STAGES = [
  { label: 'Lump', value: 'lump' },
  { label: 'Formed', value: 'formed' },
  { label: 'Trimmed', value: 'trimmed' },
  { label: 'Bisque', value: 'bisque' },
  { label: 'Glazed', value: 'glazed' },
  { label: 'Fired', value: 'fired' },
  { label: 'Archived', value: 'archived' },
  { label: 'Failed', value: 'failed' },
]
const stageLabelMap = Object.fromEntries(STAGES.map((s) => [s.value, s.label]))
const stageOrder = STAGES.map((s) => s.value)
const todayISO = () => new Date().toISOString().slice(0, 10)

/* ---------- Router ---------- */
const router = useRouter()
const route = useRoute()
const isEdit = computed(() => !!route.query.id)
const editId = computed(() => route.query.id || null)
const currentPieceId = computed(() => (isEdit.value ? parseInt(editId.value) : null))

/* ---------- Recent whatisit options ---------- */
const recentWhatisitOptions = computed(() => {
  const allPieces = piecesStore.all?.value || []
  const whatisitValues = allPieces
    .filter((p) => p.whatisit && p.whatisit.trim() !== '')
    .sort((a, b) => new Date(b.created_at) - new Date(a.created_at)) // Most recent first
    .map((p) => p.whatisit)
    .slice(0, 5) // Get the 5 most recent
  return whatisitValues
})

/* ---------- Auto-save utilities ---------- */
function showAutoSaveToast(message = 'Changes saved automatically') {
  $q.notify({
    message,
    type: 'positive',
    timeout: 1500,
    position: 'top',
    progress: true,
  })
}

async function autoSavePiece(changes) {
  if (!currentPieceId.value) return

  try {
    await piecesStore.updatePiece(currentPieceId.value, changes)
    // Reload the piece to get updated data and refresh form
    const updatedPiece = await piecesStore.getPieceById(currentPieceId.value)
    if (updatedPiece) {
      piece.value = updatedPiece
      // Update form fields that were just saved
      if (changes.visibility !== undefined) {
        form.share = updatedPiece.visibility || 'Private'
      }
      if (changes.price !== undefined) {
        form.price = updatedPiece.price || null
      }
      if (changes.is_for_sale !== undefined) {
        form.is_for_sale = updatedPiece.is_for_sale || false
      }
      if (changes.in_stock !== undefined) {
        form.in_stock = updatedPiece.in_stock !== undefined ? updatedPiece.in_stock : true
      }
    }
    showAutoSaveToast()
  } catch (error) {
    console.error('[AddPiece] Auto-save failed:', error)
    $q.notify({
      message: 'Failed to save changes',
      type: 'negative',
      timeout: 2000,
      position: 'top',
    })
  }
}

/* ---------- Form ---------- */
function emptyStageDates() {
  const obj = {}
  stageOrder.forEach((k) => (obj[k] = ''))
  return obj
}
const form = reactive({
  title: '',
  whatisit: '',
  share: 'Private',
  photos: [],
  stageLocation: '',
  stageDates: emptyStageDates(),
  stageDims: {}, // Dimensions for each stage
  stageIds: {}, // Stage IDs for updates
  clays: [],
  glazes: [],
  firings: [],
  notes: '',
  price: null,
  is_for_sale: false,
  in_stock: true,
})

/* ---------- Hydrate form ---------- */
function hydrateForm(piece) {
  form.title = piece.title
  form.whatisit = piece.whatisit || ''
  form.share = piece.visibility || 'Private'
  form.notes = piece.notes || ''
  form.price = piece.price || null
  form.is_for_sale = piece.is_for_sale || false
  form.in_stock = piece.in_stock !== undefined ? piece.in_stock : true

  form.clays =
    piece.piece_clays?.map((c) => ({
      id: c.id,
      clayId: c.clay_body?.id,
      clayName: c.clay_body?.name,
      notes: c.notes || '',
    })) || []

  form.glazes =
    piece.piece_glazes?.map((g) => ({
      id: g.id,
      glazeId: g.glaze?.id,
      notes: g.notes || '',
      layer_number: g.layer_number,
      application_method: g.application_method || '',
      application_order: g.application_order || 1,
    })) || []

  console.log(
    '[AddPiecePage] Hydrated glazes:',
    form.glazes.map((g) => ({
      id: g.id,
      glazeId: g.glazeId,
      application_order: g.application_order,
      layer_number: g.layer_number,
    })),
  )

  form.firings =
    piece.piece_firings?.map((f) => ({
      id: f.id,
      cone: f.cone,
      tempF: f.temperature_f,
      kilnType: f.kiln_type,
      kilnLocation: f.kiln_location,
      name: f.load_name,
      date: f.date,
      notes: f.notes || '',
    })) || []

  form.photos = piece.piece_images || []

  form.stageDates =
    piece.piece_stage_histories?.reduce((acc, sh) => {
      // Convert ISO date to yyyy-MM-dd format for HTML date input
      acc[sh.stage] = sh.date ? new Date(sh.date).toISOString().split('T')[0] : ''
      return acc
    }, emptyStageDates()) || emptyStageDates()

  // Load dimensions and IDs from stage histories
  form.stageDims =
    piece.piece_stage_histories?.reduce((acc, sh) => {
      acc[sh.stage] = {
        length: sh.length_cm
          ? profileStore.isMetric
            ? sh.length_cm.toFixed(1)
            : (sh.length_cm / 2.54).toFixed(1)
          : '',
        width: sh.width_cm
          ? profileStore.isMetric
            ? sh.width_cm.toFixed(1)
            : (sh.width_cm / 2.54).toFixed(1)
          : '',
        height: sh.height_cm
          ? profileStore.isMetric
            ? sh.height_cm.toFixed(1)
            : (sh.height_cm / 2.54).toFixed(1)
          : '',
        weight: sh.weight_g
          ? profileStore.isMetric
            ? sh.weight_g.toFixed(1)
            : (sh.weight_g / 453.592).toFixed(1)
          : '',
        location: sh.location || '',
      }
      return acc
    }, {}) || {}

  // Store stage IDs for updates
  form.stageIds =
    piece.piece_stage_histories?.reduce((acc, sh) => {
      acc[sh.stage] = sh.id
      return acc
    }, {}) || {}

  // Update local stage histories
  localStageHistories.value = piece.piece_stage_histories || []
}

/* ---------- Load existing if editing ---------- */
const piece = ref(null)
const localStageHistories = ref([])

async function loadPiece() {
  if (isEdit.value && editId.value) {
    isHydrating.value = true
    const loadedPiece = await piecesStore.getPieceById(editId.value)
    if (loadedPiece) {
      piece.value = loadedPiece
      hydrateForm(loadedPiece)
      // Wait for all reactive updates to complete before allowing auto-save
      await nextTick()
      // Small delay to ensure all watchers have finished
      await new Promise((resolve) => setTimeout(resolve, 100))
    }
    isHydrating.value = false
  }
}

onMounted(async () => {
  if (isEdit.value && editId.value) {
    await loadPiece()
  } else {
    // 👇 NEW auto-create logic
    const randomName = nameGen.getRandomName()
    const created = await piecesStore.createPiece({
      title: randomName,
      visibility: 'Private',
      notes: '',
    })
    piece.value = created
    form.title = created.title

    // Update URL so auto-save works everywhere
    router.replace({ name: 'addpiece', query: { id: created.id } })

    // Immediately add Lump stage
    const lumpStage = await piecesStore.addStage({
      piece_id: created.id,
      stage: 'lump',
      date: todayISO(),
    })
    form.stageDates.lump = todayISO()
    form.stageIds.lump = lumpStage.id
    form.stageDims.lump = {}

    // Initialize local stage histories with the new lump stage
    localStageHistories.value = [lumpStage]
  }

  resetDirtyBaseline()
})

// Watch for route changes to reload piece when navigating back to edit
watch(
  () => route.query.id,
  async (newId, oldId) => {
    if (newId && newId !== oldId && isEdit.value) {
      await loadPiece()
      resetDirtyBaseline()
    }
  },
)

/* ---------- Auto-save watchers ---------- */
// Flag to prevent auto-save during initial hydration
const isHydrating = ref(false)

// Auto-save title changes (with debounce)
let titleDebounce = null
watch(
  () => form.title,
  (newTitle, oldTitle) => {
    if (!isEdit.value || !currentPieceId.value || isHydrating.value) return
    if (newTitle === oldTitle) return

    clearTimeout(titleDebounce)
    titleDebounce = setTimeout(() => {
      autoSavePiece({ title: newTitle.trim() })
    }, 1000) // 1 second debounce
  },
)

// Auto-save notes changes (with debounce)
let notesDebounce = null
watch(
  () => form.notes,
  (newNotes, oldNotes) => {
    if (!isEdit.value || !currentPieceId.value || isHydrating.value) return
    if (newNotes === oldNotes) return

    clearTimeout(notesDebounce)
    notesDebounce = setTimeout(() => {
      autoSavePiece({ notes: newNotes || null })
    }, 1000) // 1 second debounce
  },
)

// Auto-save whatisit changes
let whatisitDebounce = null
watch(
  () => form.whatisit,
  (newWhatisit, oldWhatisit) => {
    if (!isEdit.value || !currentPieceId.value || isHydrating.value) return
    if (newWhatisit === oldWhatisit) return

    clearTimeout(whatisitDebounce)
    whatisitDebounce = setTimeout(() => {
      autoSavePiece({ whatisit: newWhatisit || null })
    }, 1000) // 1 second debounce
  },
)

// Auto-save share/visibility changes
watch(
  () => form.share,
  (newShare, oldShare) => {
    if (!isEdit.value || !currentPieceId.value || isHydrating.value) return
    if (newShare === oldShare) return

    autoSavePiece({ visibility: newShare || 'Private' })
  },
)

// Auto-set visibility to Public when marking for sale
watch(
  () => form.is_for_sale,
  (newIsForSale, oldIsForSale) => {
    // Skip during hydration
    if (isHydrating.value) return

    // When marking for sale, automatically set visibility to Public
    if (newIsForSale && !oldIsForSale && form.share !== 'Public') {
      form.share = 'Public'
    }
  },
)

// Auto-save price and sale status changes
let saleDebounce = null
watch(
  () => [form.price, form.is_for_sale, form.in_stock, form.share],
  (
    [newPrice, newIsForSale, newInStock, newShare],
    [oldPrice, oldIsForSale, oldInStock, oldShare],
  ) => {
    if (!isEdit.value || !currentPieceId.value || isHydrating.value) return
    if (
      newPrice === oldPrice &&
      newIsForSale === oldIsForSale &&
      newInStock === oldInStock &&
      newShare === oldShare
    )
      return

    clearTimeout(saleDebounce)
    saleDebounce = setTimeout(() => {
      // If marking for sale, ensure visibility is Public
      const visibility = newIsForSale ? 'Public' : newShare
      autoSavePiece({
        price: newPrice || null,
        is_for_sale: newIsForSale || false,
        in_stock: newIsForSale ? (newInStock !== undefined ? newInStock : true) : false,
        visibility: visibility,
      })
    }, 1000) // 1 second debounce
  },
  { deep: true },
)

// Auto-save stage changes
watch(
  () => form.stageDates,
  async (newStageDates, oldStageDates) => {
    if (!isEdit.value || !currentPieceId.value || isHydrating.value) return
    if (!oldStageDates) return // Skip initial hydration

    // Find which stage was changed
    for (const stage of stageOrder) {
      const newDate = newStageDates[stage]
      const oldDate = oldStageDates[stage]

      if (newDate !== oldDate && newDate) {
        try {
          const stageId = form.stageIds[stage]
          const dims = form.stageDims[stage] || {}

          if (stageId) {
            // Update existing stage
            await piecesStore.updateStage(stageId, {
              date: newDate,
              length_cm: dims.length
                ? profileStore.isMetric
                  ? parseFloat(dims.length)
                  : parseFloat(dims.length) * 2.54
                : null,
              width_cm: dims.width
                ? profileStore.isMetric
                  ? parseFloat(dims.width)
                  : parseFloat(dims.width) * 2.54
                : null,
              height_cm: dims.height
                ? profileStore.isMetric
                  ? parseFloat(dims.height)
                  : parseFloat(dims.height) * 2.54
                : null,
              weight_g: dims.weight
                ? profileStore.isMetric
                  ? parseFloat(dims.weight)
                  : parseFloat(dims.weight) * 453.592
                : null,
              location: dims.location || null,
            })
          } else {
            // Create new stage
            await piecesStore.addStage({
              piece_id: currentPieceId.value,
              stage: stage,
              date: newDate,
              length_cm: dims.length
                ? profileStore.isMetric
                  ? parseFloat(dims.length)
                  : parseFloat(dims.length) * 2.54
                : null,
              width_cm: dims.width
                ? profileStore.isMetric
                  ? parseFloat(dims.width)
                  : parseFloat(dims.width) * 2.54
                : null,
              height_cm: dims.height
                ? profileStore.isMetric
                  ? parseFloat(dims.height)
                  : parseFloat(dims.height) * 2.54
                : null,
              weight_g: dims.weight
                ? profileStore.isMetric
                  ? parseFloat(dims.weight)
                  : parseFloat(dims.weight) * 453.592
                : null,
              location: dims.location || null,
            })
          }
          showAutoSaveToast(`${stageLabelMap[stage]} stage saved`)
        } catch (error) {
          console.error('[AddPiece] Failed to save stage:', error)
          $q.notify({
            message: 'Failed to save stage',
            type: 'negative',
            timeout: 2000,
            position: 'top',
          })
        }
      }
    }
  },
  { deep: true },
)

// Auto-save dimension changes
watch(
  () => form.stageDims,
  async (newStageDims, oldStageDims) => {
    if (!isEdit.value || !currentPieceId.value || isHydrating.value) return
    if (!oldStageDims) return // Skip initial hydration

    // Find which stage dimensions were changed
    for (const stage of stageOrder) {
      const newDims = newStageDims[stage] || {}
      const oldDims = oldStageDims[stage] || {}

      // Check if any dimension changed
      const hasChanges =
        newDims.length !== oldDims.length ||
        newDims.width !== oldDims.width ||
        newDims.height !== oldDims.height ||
        newDims.weight !== oldDims.weight ||
        newDims.location !== oldDims.location

      if (hasChanges && form.stageDates[stage]) {
        try {
          const stageId = form.stageIds[stage]
          if (stageId) {
            // Update existing stage
            await piecesStore.updateStage(stageId, {
              length_cm: newDims.length
                ? profileStore.isMetric
                  ? parseFloat(newDims.length)
                  : parseFloat(newDims.length) * 2.54
                : null,
              width_cm: newDims.width
                ? profileStore.isMetric
                  ? parseFloat(newDims.width)
                  : parseFloat(newDims.width) * 2.54
                : null,
              height_cm: newDims.height
                ? profileStore.isMetric
                  ? parseFloat(newDims.height)
                  : parseFloat(newDims.height) * 2.54
                : null,
              weight_g: newDims.weight
                ? profileStore.isMetric
                  ? parseFloat(newDims.weight)
                  : parseFloat(newDims.weight) * 453.592
                : null,
              location: newDims.location || null,
            })
          } else {
            // Create new stage (shouldn't happen in edit mode, but fallback)
            await piecesStore.addStage({
              piece_id: currentPieceId.value,
              stage: stage,
              date: form.stageDates[stage],
              length_cm: newDims.length
                ? profileStore.isMetric
                  ? parseFloat(newDims.length)
                  : parseFloat(newDims.length) * 2.54
                : null,
              width_cm: newDims.width
                ? profileStore.isMetric
                  ? parseFloat(newDims.width)
                  : parseFloat(newDims.width) * 2.54
                : null,
              height_cm: newDims.height
                ? profileStore.isMetric
                  ? parseFloat(newDims.height)
                  : parseFloat(newDims.height) * 2.54
                : null,
              weight_g: newDims.weight
                ? profileStore.isMetric
                  ? parseFloat(newDims.weight)
                  : parseFloat(newDims.weight) * 453.592
                : null,
              location: newDims.location || null,
            })
          }
          showAutoSaveToast(`${stageLabelMap[stage]} dimensions saved`)
        } catch (error) {
          console.error('[AddPiece] Failed to save dimensions:', error)
          $q.notify({
            message: 'Failed to save dimensions',
            type: 'negative',
            timeout: 2000,
            position: 'top',
          })
        }
      }
    }
  },
  { deep: true },
)

/* ---------- Stage histories computed ---------- */
const stageHistories = computed({
  get: () => {
    console.log('[AddPiecePage] stageHistories.get() returning:', localStageHistories.value)
    return localStageHistories.value
  },
  set: (newHistories) => {
    console.log('[AddPiecePage] stageHistories.set() called with:', newHistories)
    localStageHistories.value = newHistories
  },
})

// Watch for changes in piece.stage_histories to keep local array in sync
watch(
  () => piece.value?.piece_stage_histories,
  (newHistories) => {
    if (newHistories && !isHydrating.value) {
      console.log('[AddPiecePage] piece.stage_histories changed, updating local:', newHistories)
      localStageHistories.value = newHistories
    }
  },
  { deep: true },
)

/* ---------- Latest stage ---------- */
const latestStage = computed(() => {
  // Find the latest stage from localStageHistories
  const stageWithDates = localStageHistories.value
    .filter((sh) => sh.date)
    .sort((a, b) => new Date(b.date) - new Date(a.date))

  if (stageWithDates.length > 0) {
    const latest = stageWithDates[0]
    return { key: latest.stage, date: latest.date }
  }

  // Fallback to form.stageDates for backward compatibility
  for (let i = stageOrder.length - 1; i >= 0; i--) {
    const k = stageOrder[i]
    const date = form.stageDates[k]
    if (date) return { key: k, date }
  }
  return null
})

/* ---------- Dirty tracking ---------- */
const snapshot = ref('')
const stringify = () => {
  // In edit mode, exclude auto-saved fields from dirty tracking
  if (isEdit.value) {
    // Photos are now auto-saved, so only check stageLocation for dirty state
    const { stageLocation } = form
    return JSON.stringify({ stageLocation })
  }
  // For new pieces, exclude photos from dirty check since they're auto-saved
  const rest = { ...form }
  delete rest.photos
  return JSON.stringify(rest)
}
async function resetDirtyBaseline() {
  await nextTick()
  snapshot.value = stringify()
}
const dirty = computed(() => stringify() !== snapshot.value)

/* ---------- Save ---------- */
async function onSave() {
  const pieceId = editId.value || piece.value?.id
  if (!pieceId) {
    console.error('[onSave] No pieceId available')
    return
  }

  // ensure title
  if (!form.title || form.title.trim() === '') {
    form.title = nameGen.getRandomName()
    await piecesStore.updatePiece(pieceId, { title: form.title })
  }

  // Save price and sale status
  // If marking for sale, ensure visibility is Public
  const visibility = form.is_for_sale ? 'Public' : form.share

  await piecesStore.updatePiece(pieceId, {
    price: form.price || null,
    is_for_sale: form.is_for_sale || false,
    in_stock: form.is_for_sale ? (form.in_stock !== undefined ? form.in_stock : true) : false,
    visibility: visibility,
  })

  // Reload the piece to get updated data
  const updatedPiece = await piecesStore.getPieceById(pieceId)
  if (updatedPiece) {
    piece.value = updatedPiece
    hydrateForm(updatedPiece)
  }

  // 🔹 Save clays
  for (const clay of form.clays) {
    if (clay.clayId && !clay.id) {
      await piecesStore.addClayToPiece({
        piece_id: pieceId,
        clay_body_id: clay.clayId,
        notes: clay.notes || null,
      })
    }
  }

  // 🔹 Save glazes
  for (const glaze of form.glazes) {
    if (glaze.glazeId && !glaze.id) {
      await piecesStore.addGlazeToPiece({
        piece_id: pieceId,
        glaze_id: glaze.glazeId,
        layer_number: glaze.layer_number || 1,
        application_method: glaze.application_method || null,
        notes: glaze.notes || null,
      })
    }
  }

  // 🔹 Save firings
  for (const firing of form.firings) {
    if (firing.cone && !firing.id) {
      await piecesStore.addFiring({
        piece_id: pieceId,
        cone: firing.cone,
        temperature_f: firing.tempF || null,
        kiln_type: firing.kilnType || null,
        kiln_location: firing.kilnLocation || null,
        load_name: firing.name || null,
        date: firing.date || null,
        notes: firing.notes || null,
      })
    }
  }

  // 🔹 Photos are now auto-saved by PhotoGalleryEditor
  // No manual photo upload needed here anymore

  await resetDirtyBaseline()
  showAutoSaveToast('Piece completed!')
  router.push({ name: 'shelf' })
}

/* ---------- Cancel / Leave guards ---------- */
function handleCancel() {
  if (!dirty.value) return router.back()
  if (confirm('Discard unsaved changes?')) router.back()
}
function beforeUnload(e) {
  if (!dirty.value) return
  e.preventDefault()
  e.returnValue = ''
}
watch(
  dirty,
  (v) => {
    if (v) window.addEventListener('beforeunload', beforeUnload)
    else window.removeEventListener('beforeunload', beforeUnload)
  },
  { immediate: true },
)
onBeforeUnmount(() => window.removeEventListener('beforeunload', beforeUnload))
onBeforeRouteLeave((_, __, next) => {
  if (!dirty.value) return next()
  if (confirm('You have unsaved changes. Discard and leave?')) next()
  else next(false)
})
</script>
