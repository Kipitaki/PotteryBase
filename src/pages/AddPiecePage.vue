<template>
  <q-page padding class="bg-grey-1">
    <q-form @submit.prevent="onSave">
      <!-- Header -->
      <piece-header-bar
        v-model:title="form.title"
        v-model:share="form.share"
        :latest="latestStage"
        :stage-label-map="stageLabelMap"
      />

      <!-- Photos -->
      <photo-gallery-editor v-model="form.photos" class="q-mb-md" />

      <div class="row q-col-gutter-md">
        <!-- LEFT: Stages -->
        <div class="col-12 col-md-4">
          <stage-checklist
            :stages="STAGES"
            v-model:stageDates="form.stageDates"
            v-model:stageLocation="form.stageLocation"
          />
        </div>

        <!-- RIGHT: Clay / Glaze / Firing / Notes -->
        <div class="col-12 col-md-8">
          <clay-picker v-model="form.clays" :piece-id="currentPieceId" />
          <glaze-rows-editor v-model="form.glazes" :piece-id="currentPieceId" />
          <firing-rows-editor v-model="form.firings" :piece-id="currentPieceId" />

          <section-card>
            <template #title>Notes</template>
            <q-input
              v-model="form.notes"
              type="textarea"
              autogrow
              dense
              placeholder="Anything else to remember"
            />
          </section-card>
        </div>
      </div>

      <!-- Actions -->
      <div class="row items-center justify-between q-gutter-sm q-mt-md">
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
          <q-btn color="primary" :label="isEdit ? 'Save Changes' : 'Save Piece'" type="submit" />
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
import SectionCard from 'src/components/SectionCard.vue'
import { useNameGeneratorStore } from 'src/stores/nameGenerator'
import { usePiecesStore } from 'src/stores/pieces'
import { nhost } from 'boot/nhost'

const piecesStore = usePiecesStore()
const nameGen = useNameGeneratorStore()
const $q = useQuasar()

/* ---------- Stages ---------- */
const STAGES = [
  { label: 'Lump', value: 'lump' },
  { label: 'Formed', value: 'formed' },
  { label: 'Trimmed', value: 'trimmed' },
  { label: 'Bisque', value: 'bisque' },
  { label: 'Glazed', value: 'glazed' },
  { label: 'Fired', value: 'fired' },
  { label: 'Sold/Posted', value: 'sold_posted' },
  { label: 'Sold/Kept', value: 'sold_kept' },
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
  share: 'private',
  photos: [],
  stageLocation: '',
  stageDates: { ...emptyStageDates(), lump: todayISO() },
  clays: [],
  glazes: [],
  firings: [],
  notes: '',
})

/* ---------- Hydrate form ---------- */
function hydrateForm(piece) {
  form.title = piece.title
  form.share = piece.visibility || 'private'
  form.notes = piece.notes || ''

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
      layer: g.layer_number,
    })) || []

  form.firings = piece.piece_firings || []

  form.photos = piece.piece_images || []

  form.stageDates =
    piece.piece_stage_histories?.reduce((acc, sh) => {
      acc[sh.stage] = sh.date
      return acc
    }, emptyStageDates()) || emptyStageDates()
}

/* ---------- Load existing if editing ---------- */
onMounted(async () => {
  if (isEdit.value && editId.value) {
    const piece = await piecesStore.getPieceById(editId.value)
    if (piece) hydrateForm(piece)
  }
  resetDirtyBaseline()
})

/* ---------- Auto-save watchers ---------- */
// Auto-save title changes (with debounce)
let titleDebounce = null
watch(
  () => form.title,
  (newTitle, oldTitle) => {
    if (!isEdit.value || !currentPieceId.value) return
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
    if (!isEdit.value || !currentPieceId.value) return
    if (newNotes === oldNotes) return

    clearTimeout(notesDebounce)
    notesDebounce = setTimeout(() => {
      autoSavePiece({ notes: newNotes || null })
    }, 1000) // 1 second debounce
  },
)

// Auto-save share/visibility changes
watch(
  () => form.share,
  (newShare, oldShare) => {
    if (!isEdit.value || !currentPieceId.value) return
    if (newShare === oldShare) return

    autoSavePiece({ visibility: newShare })
  },
)

// Auto-save stage changes
watch(
  () => form.stageDates,
  async (newStageDates, oldStageDates) => {
    if (!isEdit.value || !currentPieceId.value) return
    if (!oldStageDates) return // Skip initial hydration

    // Find which stage was changed
    for (const stage of stageOrder) {
      const newDate = newStageDates[stage]
      const oldDate = oldStageDates[stage]

      if (newDate !== oldDate && newDate) {
        try {
          await piecesStore.addStage({
            piece_id: currentPieceId.value,
            stage: stage,
            date: newDate,
          })
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

/* ---------- Latest stage ---------- */
const latestStage = computed(() => {
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
    // const { title, notes, share, stageDates, clays, glazes, firings, ...rest } = form
    //return JSON.stringify(rest)
    const { photos, stageLocation } = form
    return JSON.stringify({ photos, stageLocation })
  }
  return JSON.stringify(form)
}
async function resetDirtyBaseline() {
  await nextTick()
  snapshot.value = stringify()
}
const dirty = computed(() => stringify() !== snapshot.value)

/* ---------- Save ---------- */
async function onSave() {
  let pieceId = editId.value

  // ensure title
  if (!form.title || form.title.trim() === '') {
    form.title = nameGen.getRandomName()
  }

  if (isEdit.value && pieceId) {
    // In edit mode, most fields are auto-saved, just handle photos
    // Title, notes, share, stages, clays, glazes, firings are auto-saved
  } else {
    // Create new piece
    const created = await piecesStore.createPiece({
      title: form.title,
      visibility: form.share,
      notes: form.notes,
    })
    pieceId = created.id

    // Update the URL to enable auto-save for components
    router.replace({
      name: 'addpiece',
      query: { id: pieceId },
    })

    // Add initial stage if set
    if (latestStage.value) {
      await piecesStore.addStage({
        piece_id: pieceId,
        stage: latestStage.value.key,
        date: latestStage.value.date,
      })
    }

    // Save all stages that have dates
    for (const stage of stageOrder) {
      const date = form.stageDates[stage]
      if (date && stage !== latestStage.value?.key) {
        await piecesStore.addStage({
          piece_id: pieceId,
          stage: stage,
          date: date,
        })
      }
    }

    // Save clays
    for (const clay of form.clays) {
      if (clay.clayId) {
        await piecesStore.addClayToPiece({
          piece_id: pieceId,
          clay_body_id: clay.clayId,
          notes: clay.notes || null,
        })
      }
    }

    // Save glazes
    for (const glaze of form.glazes) {
      if (glaze.glazeId) {
        await piecesStore.addGlazeToPiece({
          piece_id: pieceId,
          glaze_id: glaze.glazeId,
          layer_number: glaze.layer || 1,
          notes: glaze.notes || null,
        })
      }
    }

    // Save firings
    for (const firing of form.firings) {
      if (firing.cone) {
        await piecesStore.addFiring({
          piece_id: pieceId,
          cone: firing.cone,
          temperature_f: firing.temperature || null,
          kiln_type: firing.atmosphere || null,
          notes: firing.notes || null,
        })
      }
    }
  }

  // Handle photo uploads (only field that still needs manual save)
  for (const p of form.photos) {
    if (!p.file) continue
    const { fileMetadata, error } = await nhost.storage.upload({
      file: p.file,
      bucketId: 'default',
      options: { public: true },
    })
    if (error) {
      console.error('Photo upload failed:', error)
      continue
    }
    const url = nhost.storage.getPublicUrl({ fileId: fileMetadata.id })
    await piecesStore.addImage({
      piece_id: pieceId,
      file_id: fileMetadata.id,
      url,
      stage: p.stage,
      notes: p.notes,
      is_main: p.is_main,
    })
  }

  await resetDirtyBaseline()
  showAutoSaveToast('Piece saved successfully!')
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
