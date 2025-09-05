<template>
  <section-card>
    <template #title>Clays</template>

    <!-- Recent clay pills (from DB) -->
    <template #actions>
      <div class="row items-center q-gutter-xs">
        <q-chip
          v-for="c in recentClays"
          :key="c.id"
          dense
          clickable
          outline
          color="grey-6"
          @click="quickAdd(c.id, c.label)"
        >
          {{ c.label }}
        </q-chip>
      </div>
    </template>

    <!-- Search / Add -->
    <div class="q-mb-sm" style="max-width: 420px">
      <q-select
        v-model="quickPick"
        :options="filteredAll"
        option-value="id"
        option-label="label"
        emit-value
        map-options
        label="Search / Add Clay"
        dense
        use-input
        input-debounce="0"
        clearable
        hide-bottom-space
        @filter="filterAll"
        @update:model-value="onQuickPick"
        :new-value-mode="'add-unique'"
        @new-value="onQuickNew"
      />
    </div>

    <!-- No clays yet -->
    <div v-if="!rowsValue.length" class="text-grey-7">No clays yet.</div>

    <!-- Clay rows -->
    <div
      v-for="(c, i) in rowsValue"
      :key="c.id ?? `local-${c.clayId}`"
      class="row items-center no-wrap q-col-gutter-sm q-mb-xs"
    >
      <!-- Clay select (shows chip when selected) -->
      <div class="col-auto" style="min-width: 240px; max-width: 320px">
        <q-select
          v-model="c.clayId"
          :options="filteredAll"
          option-value="id"
          option-label="label"
          emit-value
          map-options
          label="Clay"
          dense
          use-input
          input-debounce="0"
          clearable
          hide-bottom-space
          @filter="filterAll"
          @update:model-value="(val) => onRowClayChanged(i, val)"
        >
          <!-- Custom selected template -->
          <template #selected>
            <q-chip v-if="c.clayId" dense square :color="chipColor(c.clayId)" text-color="white">
              {{ getClayLabel(c.clayId) }}
            </q-chip>
            <span v-else>Clay</span>
          </template>
        </q-select>
      </div>

      <!-- Notes -->
      <div class="col" style="min-width: 180px">
        <q-input
          v-model="c.notes"
          label="Notes"
          dense
          hide-bottom-space
          @update:model-value="(val) => onNotesChanged(i, val)"
        />
      </div>

      <!-- Remove -->
      <div class="col-auto">
        <q-btn flat dense round icon="close" color="negative" @click="remove(i)" />
      </div>
    </div>
  </section-card>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import SectionCard from './SectionCard.vue'
import { useClaysStore } from 'src/stores/clays' // <-- use the rewritten clays store
import { usePiecesStore } from 'src/stores/pieces' // <-- for auto-save operations
import { Notify } from 'quasar'

const props = defineProps({
  modelValue: { type: Array, default: () => [] }, // rows live in parent; we only emit updates
  pieceId: { type: Number, default: null }, // piece ID for auto-save
})
const emit = defineEmits(['update:modelValue'])

const claysStore = useClaysStore()
const piecesStore = usePiecesStore()

// Auto-save mode when pieceId is provided
const isAutoSaveMode = computed(() => props.pieceId !== null)

function showAutoSaveToast(message = 'Clay updated') {
  if (isAutoSaveMode.value) {
    Notify.create({
      message,
      type: 'positive',
      timeout: 1500,
      position: 'top',
      progress: true,
    })
  }
}

const rowsValue = computed(() => props.modelValue || [])

/* ---- Options ---- */
const allOptions = computed(() => claysStore.options.value || [])
const filteredAll = ref([])
watch(allOptions, (v) => (filteredAll.value = (v || []).slice()), { immediate: true })

function filterAll(val, update) {
  update(() => {
    const needle = (val || '').toLowerCase()
    const base = allOptions.value || []
    filteredAll.value = needle
      ? base.filter((o) => o.label.toLowerCase().includes(needle))
      : base.slice()
  })
}
function chipColor(clayId) {
  // deterministic but varied coloring
  const colors = ['blue', 'green', 'orange', 'purple', 'teal', 'red']
  const idx =
    Math.abs(
      String(clayId)
        .split('')
        .reduce((acc, c) => acc + c.charCodeAt(0), 0),
    ) % colors.length
  return colors[idx]
}
/* ---- Recent clays from DB (to pills) ---- */
const recentClays = computed(() => {
  const rec = claysStore.recent.value || []
  return rec.map((c) => ({
    id: c.id,
    label: `${c.name}${c.brand ? ' (' + c.brand + ')' : ''}`,
  }))
})

/* ---- Label helper ---- */
function getClayLabel(id) {
  const opt = (allOptions.value || []).find((o) => o.id === id)
  return opt ? opt.label : ''
}

/* ---- Local add / change / remove ---- */
async function addClayRow(clayId, clayName = '') {
  if (!clayId) return

  // prevent duplicate clay on this piece (local)
  const exists = rowsValue.value.some((r) => String(r.clayId) === String(clayId))
  if (exists) return

  const newRow = { id: null, clayId, clayName, notes: '' }

  // Auto-save to database if pieceId is provided
  if (isAutoSaveMode.value) {
    try {
      const result = await piecesStore.addClayToPiece({
        piece_id: props.pieceId,
        clay_body_id: clayId,
        notes: '',
      })
      // Update the row with the returned ID
      newRow.id = result.id
      showAutoSaveToast('Clay added')
    } catch (error) {
      console.error('[ClayPicker] Failed to save clay to database:', error)
      return // Don't add to UI if save failed
    }
  }

  const next = [...rowsValue.value, newRow]
  emit('update:modelValue', next)
}

async function onRowClayChanged(idx, clayId) {
  const currentRow = rowsValue.value[idx]
  const label = getClayLabel(clayId) || ''

  // Auto-save to database if pieceId is provided and row has ID
  if (isAutoSaveMode.value && currentRow.id) {
    try {
      await piecesStore.updatePieceClayRow(currentRow.id, {
        clay_body_id: clayId,
      })
      showAutoSaveToast('Clay updated')
    } catch (error) {
      console.error('[ClayPicker] Failed to update clay in database:', error)
      return // Don't update UI if save failed
    }
  }

  const next = rowsValue.value.map((r, i) => (i === idx ? { ...r, clayId, clayName: label } : r))
  emit('update:modelValue', next)
}

async function onNotesChanged(idx, notes) {
  const currentRow = rowsValue.value[idx]

  // Auto-save to database if pieceId is provided and row has ID
  if (isAutoSaveMode.value && currentRow.id) {
    try {
      await piecesStore.updatePieceClayRow(currentRow.id, {
        notes,
      })
      showAutoSaveToast('Notes updated')
    } catch (error) {
      console.error('[ClayPicker] Failed to update notes in database:', error)
      return // Don't update UI if save failed
    }
  }

  const next = rowsValue.value.map((r, i) => (i === idx ? { ...r, notes } : r))
  emit('update:modelValue', next)
}

async function remove(i) {
  const rowToRemove = rowsValue.value[i]

  // Auto-save to database if pieceId is provided and row has ID
  if (isAutoSaveMode.value && rowToRemove.id) {
    try {
      await piecesStore.deletePieceClayRow(rowToRemove.id)
      showAutoSaveToast('Clay removed')
    } catch (error) {
      console.error('[ClayPicker] Failed to delete clay from database:', error)
      return // Don't remove from UI if delete failed
    }
  }

  const next = [...rowsValue.value]
  next.splice(i, 1)
  emit('update:modelValue', next)
}

/* ---- Quick actions ---- */
async function quickAdd(id, label) {
  await addClayRow(id, label)
}

const quickPick = ref(null)
async function onQuickPick(id) {
  if (!id) return
  const label = getClayLabel(id) || ''
  await addClayRow(id, label)
  quickPick.value = null
}

async function onQuickNew(text) {
  const name = (text || '').trim()
  if (!name) return
  try {
    // create in master list first
    const created = await claysStore.createClayBody({ name })
    await claysStore.refetch()
    await claysStore.refetchRecent()

    // then add locally so your page save loop will insert the junction row
    await addClayRow(created.id, created.name)
    quickPick.value = null
  } catch (e) {
    console.error('[ClayPicker] onQuickNew failed:', e)
  }
}
</script>
