<template>
  <section-card>
    <template #title>Glazes</template>

    <!-- Recent glaze pills (from DB) -->
    <template #actions>
      <div class="row items-center q-gutter-xs">
        <q-chip
          v-for="g in recentGlazes"
          :key="g.id"
          dense
          clickable
          outline
          color="grey-6"
          @click="quickAdd(g.id, g.label)"
        >
          {{ g.label }}
        </q-chip>
      </div>
    </template>

    <!-- Search / Add -->
    <div class="q-mb-sm" style="max-width: 420px">
      <q-select
        v-model="quickPick"
        :options="filteredAllWithAddOption"
        option-value="id"
        option-label="label"
        emit-value
        map-options
        label="Search / Add Glaze"
        dense
        use-input
        input-debounce="0"
        clearable
        hide-bottom-space
        @filter="filterAll"
        @update:model-value="onQuickPick"
      />
    </div>

    <!-- No glazes yet -->
    <div v-if="!rowsValue.length" class="text-grey-7">No glazes yet.</div>

    <!-- Add Glaze Dialog -->
    <AddGlazeDialog v-model="showAddGlazeDialog" @glaze-added="onNewGlazeAdded" />

    <!-- Glaze rows -->
    <draggable
      v-model="glazeRows"
      item-key="id"
      @change="onDragChange"
      :disabled="!isAutoSaveMode"
      handle=".drag-handle"
    >
      <template #item="{ element: g, index: i }">
        <div class="row items-center no-wrap q-col-gutter-sm q-mb-xs">
          <!-- Drag handle -->
          <div class="col-auto drag-handle" style="cursor: grab">
            <q-icon name="drag_indicator" color="grey-5" size="18px" />
          </div>

          <!-- Application order -->
          <div class="col-auto">
            <q-chip dense color="primary" text-color="white" size="sm">
              #{{ g.application_order || 1 }}
            </q-chip>
          </div>

          <!-- Glaze display chip (read-only) -->
          <div class="col-auto">
            <q-chip
              v-if="g.glazeId"
              dense
              square
              :color="chipColor(g.glazeId)"
              text-color="white"
              size="md"
            >
              {{ getGlazeName(g.glazeId) }}
            </q-chip>
            <span v-else class="text-grey-6">No glaze selected</span>
          </div>

          <!-- Layer number -->
          <div class="col-auto" style="min-width: 75px; max-width: 50px">
            <q-input
              v-model="g.layer_number"
              type="number"
              label="Layer"
              dense
              hide-bottom-space
              @update:model-value="(val) => onFieldChange(i, 'layer_number', val)"
            />
          </div>

          <!-- Application method -->
          <div class="col-auto" style="min-width: 140px; max-width: 200px">
            <q-input
              v-model="g.application_method"
              label="Method"
              dense
              hide-bottom-space
              @update:model-value="(val) => onFieldChange(i, 'application_method', val)"
            />
          </div>

          <!-- Notes -->
          <div class="col">
            <q-input
              v-model="g.notes"
              label="Notes"
              dense
              hide-bottom-space
              @update:model-value="(val) => onFieldChange(i, 'notes', val)"
            />
          </div>

          <!-- Remove -->
          <div class="col-auto">
            <q-btn flat dense round icon="close" color="negative" @click="remove(i)" />
          </div>
        </div>
      </template>
    </draggable>
  </section-card>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import SectionCard from './SectionCard.vue'
import AddGlazeDialog from './AddGlazeDialog.vue'
import { useGlazesStore } from 'src/stores/glazes' // <-- we'll build this next
import { usePiecesStore } from 'src/stores/pieces' // <-- for auto-save operations
import { Notify } from 'quasar'
import draggable from 'vuedraggable'

const props = defineProps({
  modelValue: { type: Array, default: () => [] },
  pieceId: { type: Number, default: null }, // piece ID for auto-save
  isHydrating: { type: Boolean, default: false }, // prevent auto-save during initial data loading
})

const emit = defineEmits(['update:modelValue'])

const glazesStore = useGlazesStore()
const piecesStore = usePiecesStore()

// Auto-save mode when pieceId is provided
const isAutoSaveMode = computed(() => props.pieceId !== null)

function showAutoSaveToast(message = 'Glaze updated') {
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

// Computed property for drag/drop that reverses order for display (bottom-to-top)
const glazeRows = computed({
  get: () => {
    // Display in reverse order (bottom-to-top application order)
    return [...rowsValue.value].sort(
      (a, b) => (b.application_order || 0) - (a.application_order || 0),
    )
  },
  set: (newOrder) => {
    // When dragged, update application_order based on new positions
    // newOrder is in display order (reversed), so we need to reverse again for application order
    const updatedRows = newOrder.map((row, index) => ({
      ...row,
      application_order: newOrder.length - index, // Reverse the index for application order
    }))
    emit('update:modelValue', updatedRows)
  },
})

/* ---- Options ---- */
const allOptions = computed(() => glazesStore.options.value || [])
const filteredAll = ref([])
const showAddGlazeDialog = ref(false)

watch(allOptions, (v) => (filteredAll.value = (v || []).slice()), { immediate: true })

// Computed property that adds "Add New Glaze" option when no results found
const filteredAllWithAddOption = computed(() => {
  const base = filteredAll.value || []
  const hasResults = base.length > 0

  if (!hasResults) {
    return [
      {
        id: 'add-new-glaze',
        label: '+ Add New Glaze',
        isAddOption: true,
      },
    ]
  }

  return base
})

function filterAll(val, update) {
  update(() => {
    const needle = (val || '').toLowerCase()
    const base = allOptions.value || []
    filteredAll.value = needle
      ? base.filter((o) => o.label.toLowerCase().includes(needle))
      : base.slice()
  })
}

/* ---- Recent glazes from DB (to pills) ---- */
const recentGlazes = computed(() => {
  const rec = glazesStore.recent.value || []
  return rec.map((g) => ({
    id: g.id,
    label: `${g.name}${g.brand ? ' (' + g.brand + ')' : ''}`,
  }))
})

/* ---- Label helper ---- */
function getGlazeLabel(id) {
  const opt = (allOptions.value || []).find((o) => o.id === id)
  return opt ? opt.label : ''
}

/* ---- Drag and drop ---- */
async function onDragChange() {
  // Update application_order for all rows in the database
  if (!isAutoSaveMode.value) return

  const currentRows = glazeRows.value

  for (let i = 0; i < currentRows.length; i++) {
    const row = currentRows[i]
    const newOrder = currentRows.length - i // Reverse order for application

    if (row.id && row.application_order !== newOrder) {
      try {
        await piecesStore.updatePieceGlaze(row.id, {
          application_order: newOrder,
        })
      } catch (error) {
        console.error('[GlazeRowsEditor] Failed to update glaze order:', error)
      }
    }
  }

  if (currentRows.length > 0) {
    showAutoSaveToast('Glaze order updated')
  }
}

/* ---- Local add / change / remove ---- */
async function addGlazeRow(glazeId, glazeName = '') {
  if (!glazeId) return

  const exists = rowsValue.value.some((r) => String(r.glazeId) === String(glazeId))
  if (exists) return

  // Calculate next order number (highest existing order + 1)
  const maxOrder = Math.max(0, ...rowsValue.value.map((r) => r.application_order || 0))
  const nextOrder = maxOrder + 1

  const newRow = {
    id: null,
    glazeId,
    glazeName,
    layer_number: null,
    application_method: '',
    application_order: nextOrder,
    notes: '',
  }

  // Auto-save to database if pieceId is provided
  if (isAutoSaveMode.value) {
    try {
      const result = await piecesStore.addGlazeToPiece({
        piece_id: props.pieceId,
        glaze_id: glazeId,
        notes: '',
        layer_number: 1,
        application_method: null,
        application_order: nextOrder,
      })
      // Update the row with the returned ID
      newRow.id = result.id
      showAutoSaveToast('Glaze added')
    } catch (error) {
      console.error('[GlazeRowsEditor] Failed to save glaze to database:', error)
      return // Don't add to UI if save failed
    }
  }

  const next = [...rowsValue.value, newRow]
  emit('update:modelValue', next)
}

async function remove(i) {
  const rowToRemove = rowsValue.value[i]

  // Auto-save to database if pieceId is provided and row has ID
  if (isAutoSaveMode.value && rowToRemove.id) {
    try {
      await piecesStore.deletePieceGlaze(rowToRemove.id)
      showAutoSaveToast('Glaze removed')
    } catch (error) {
      console.error('[GlazeRowsEditor] Failed to delete glaze from database:', error)
      return // Don't remove from UI if delete failed
    }
  }

  // Remove the glaze from the array
  const next = [...rowsValue.value]
  next.splice(i, 1)

  // Reorder the remaining glazes to be sequential (1, 2, 3, etc.)
  const reorderedGlazes = next.map((glaze, index) => ({
    ...glaze,
    application_order: index + 1,
  }))

  // Update the database with new order numbers
  if (isAutoSaveMode.value) {
    for (let j = 0; j < reorderedGlazes.length; j++) {
      const glaze = reorderedGlazes[j]
      if (glaze.id && glaze.application_order !== j + 1) {
        try {
          await piecesStore.updatePieceGlaze(glaze.id, {
            application_order: j + 1,
          })
        } catch (error) {
          console.error('[GlazeRowsEditor] Failed to update glaze order after deletion:', error)
        }
      }
    }
  }

  emit('update:modelValue', reorderedGlazes)
}

async function onFieldChange(idx, field, value) {
  const currentRow = rowsValue.value[idx]

  // Auto-save to database if pieceId is provided and row has ID
  if (isAutoSaveMode.value && currentRow.id && !props.isHydrating) {
    try {
      const payload = {}
      payload[field] = value

      await piecesStore.updatePieceGlaze(currentRow.id, payload)
      showAutoSaveToast('Glaze updated')
    } catch (error) {
      console.error('[GlazeRowsEditor] Failed to update glaze field in database:', error)
      return // Don't update UI if save failed
    }
  }

  // Update local state
  const next = rowsValue.value.map((r, i) => (i === idx ? { ...r, [field]: value } : r))
  emit('update:modelValue', next)
}

/* ---- Quick actions ---- */
const quickPick = ref(null)

async function quickAdd(id, label) {
  await addGlazeRow(id, label)
}

function getGlazeName(id) {
  const opt = (allOptions.value || []).find((o) => o.id === id)
  return opt ? opt.name : ''
}

function chipColor(glazeId) {
  const colors = ['blue', 'green', 'orange', 'purple', 'teal', 'red']
  const idx =
    Math.abs(
      String(glazeId)
        .split('')
        .reduce((acc, c) => acc + c.charCodeAt(0), 0),
    ) % colors.length
  return colors[idx]
}

async function onQuickPick(id) {
  if (!id) return

  // Check if this is the "Add New Glaze" option
  if (id === 'add-new-glaze') {
    showAddGlazeDialog.value = true
    quickPick.value = null
    return
  }

  const label = getGlazeLabel(id) || ''
  await addGlazeRow(id, label)
  quickPick.value = null
}

// Handle when a new glaze is added via the dialog
async function onNewGlazeAdded(newGlaze) {
  // Add the newly created glaze to the current piece
  await addGlazeRow(newGlaze.id, newGlaze.name)
}
</script>
