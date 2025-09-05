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
        :options="filteredAll"
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
        :new-value-mode="'add-unique'"
        @new-value="onQuickNew"
      />
    </div>

    <!-- No glazes yet -->
    <div v-if="!rowsValue.length" class="text-grey-7">No glazes yet.</div>

    <!-- Glaze rows -->
    <div
      v-for="(g, i) in rowsValue"
      :key="g.id ?? `local-${g.glazeId}`"
      class="row items-center no-wrap q-col-gutter-sm q-mb-xs"
    >
      <!-- Select shows chip with glaze name -->
      <div class="col-auto" style="min-width: 240px; max-width: 320px">
        <q-select
          v-model="g.glazeId"
          :options="filteredAll"
          option-value="id"
          option-label="label"
          emit-value
          map-options
          label="Glaze"
          dense
          use-input
          input-debounce="0"
          clearable
          hide-bottom-space
          @filter="filterAll"
          @update:model-value="(val) => onRowGlazeChanged(i, val)"
        >
          <template #selected>
            <q-chip v-if="g.glazeId" dense square :color="chipColor(g.glazeId)" text-color="white">
              {{ getGlazeName(g.glazeId) }}
            </q-chip>
            <span v-else>Glaze</span>
          </template>
        </q-select>
      </div>

      <!-- Layer number -->
      <div class="col-2">
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
      <div class="col-3">
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
  </section-card>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import SectionCard from './SectionCard.vue'
import { useGlazesStore } from 'src/stores/glazes' // <-- we'll build this next
import { usePiecesStore } from 'src/stores/pieces' // <-- for auto-save operations
import { Notify } from 'quasar'

const props = defineProps({
  modelValue: { type: Array, default: () => [] },
  pieceId: { type: Number, default: null }, // piece ID for auto-save
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

/* ---- Options ---- */
const allOptions = computed(() => glazesStore.options.value || [])
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

/* ---- Local add / change / remove ---- */
async function addGlazeRow(glazeId, glazeName = '') {
  if (!glazeId) return

  const exists = rowsValue.value.some((r) => String(r.glazeId) === String(glazeId))
  if (exists) return

  const newRow = {
    id: null,
    glazeId,
    glazeName,
    layer_number: null,
    application_method: '',
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

async function onRowGlazeChanged(idx, glazeId) {
  const currentRow = rowsValue.value[idx]
  const label = getGlazeLabel(glazeId) || ''

  // Auto-save to database if pieceId is provided and row has ID
  if (isAutoSaveMode.value && currentRow.id) {
    try {
      await piecesStore.updatePieceGlaze(currentRow.id, {
        glaze_id: glazeId,
      })
      showAutoSaveToast('Glaze updated')
    } catch (error) {
      console.error('[GlazeRowsEditor] Failed to update glaze in database:', error)
      return // Don't update UI if save failed
    }
  }

  const next = rowsValue.value.map((r, i) => (i === idx ? { ...r, glazeId, glazeName: label } : r))
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

  const next = [...rowsValue.value]
  next.splice(i, 1)
  emit('update:modelValue', next)
}

async function onFieldChange(idx, field, value) {
  const currentRow = rowsValue.value[idx]

  // Auto-save to database if pieceId is provided and row has ID
  if (isAutoSaveMode.value && currentRow.id) {
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
  const label = getGlazeLabel(id) || ''
  await addGlazeRow(id, label)
  quickPick.value = null
}

async function onQuickNew(text) {
  const name = (text || '').trim()
  if (!name) return
  try {
    const created = await glazesStore.createGlaze({ name })
    await glazesStore.refetch()
    await glazesStore.refetchRecent()

    await addGlazeRow(created.id, created.name)
    quickPick.value = null
  } catch (e) {
    console.error('[GlazePicker] onQuickNew failed:', e)
  }
}
</script>
