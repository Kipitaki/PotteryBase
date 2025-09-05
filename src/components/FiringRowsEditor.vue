<template>
  <section-card>
    <template #title>Firings</template>
    <template #actions>
      <div class="row items-center q-gutter-xs">
        <q-chip
          v-for="cone in recentCones"
          :key="cone.id"
          dense
          clickable
          outline
          color="grey-6"
          @click="quickAddCone(cone.id)"
        >
          {{ cone.label }}
        </q-chip>
      </div>
    </template>

    <!-- Add firing -->
    <div class="q-mb-sm">
      <q-btn flat dense icon="add" label="Add Firing" color="primary" @click="addRow" />
    </div>

    <div v-if="!rowsValue.length" class="text-grey-7">No firings yet.</div>

    <div
      v-for="(f, i) in rowsValue"
      :key="f.id ?? `local-${i}`"
      class="row items-center no-wrap q-col-gutter-sm q-mb-xs"
    >
      <!-- Cone -->
      <div class="col-auto" style="width: 120px">
        <q-select
          v-model="f.cone"
          :options="['06', '04', '6', '10']"
          dense
          hide-bottom-space
          emit-value
          placeholder=" "
          map-options
          @update:model-value="(val) => onFieldChange(i, 'cone', val)"
        >
          <template #selected>
            <q-chip v-if="f.cone" dense square color="indigo" text-color="white">
              Cone {{ f.cone }}
            </q-chip>
            <span v-else>Cone</span>
          </template>
        </q-select>
      </div>

      <!-- Temp (F) -->
      <div class="col-auto" style="width: 100px">
        <q-input
          v-model="f.tempF"
          label="Temp (°F)"
          dense
          hide-bottom-space
          @update:model-value="(val) => onFieldChange(i, 'tempF', val)"
        />
      </div>

      <!-- Kiln Type -->
      <div class="col-auto" style="width: 120px">
        <q-input
          v-model="f.kilnType"
          label="Kiln Type"
          dense
          hide-bottom-space
          @update:model-value="(val) => onFieldChange(i, 'kilnType', val)"
        />
      </div>

      <!-- Kiln Location -->
      <div class="col-auto" style="width: 150px">
        <q-input
          v-model="f.kilnLocation"
          label="Kiln Location"
          dense
          hide-bottom-space
          @update:model-value="(val) => onFieldChange(i, 'kilnLocation', val)"
        />
      </div>

      <!-- Load Name -->
      <div class="col-auto" style="width: 150px">
        <q-input
          v-model="f.name"
          label="Load Name"
          dense
          hide-bottom-space
          @update:model-value="(val) => onFieldChange(i, 'name', val)"
        />
      </div>

      <!-- Date -->
      <div class="col-auto" style="width: 150px">
        <q-input
          v-model="f.date"
          type="date"
          label="Date"
          dense
          hide-bottom-space
          @update:model-value="(val) => onFieldChange(i, 'date', val)"
        />
      </div>

      <!-- Notes -->
      <div class="col" style="min-width: 200px">
        <q-input
          v-model="f.notes"
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
import { computed } from 'vue'
import SectionCard from './SectionCard.vue'
import { useFiringsStore } from 'src/stores/firings'
import { usePiecesStore } from 'src/stores/pieces' // <-- for auto-save operations
import { Notify } from 'quasar'

const firingsStore = useFiringsStore()
const piecesStore = usePiecesStore()
const recentCones = firingsStore.recentCones

const props = defineProps({
  modelValue: { type: Array, default: () => [] },
  pieceId: { type: Number, default: null }, // piece ID for auto-save
})
const emit = defineEmits(['update:modelValue'])

const rowsValue = computed(() => props.modelValue || [])

// Auto-save mode when pieceId is provided
const isAutoSaveMode = computed(() => props.pieceId !== null)

function showAutoSaveToast(message = 'Firing updated') {
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

async function quickAddCone(cone) {
  const newRow = {
    id: null,
    cone: cone,
    tempF: '',
    kilnType: '',
    kilnLocation: '',
    name: '',
    date: '',
    notes: '',
  }

  // Auto-save to database if pieceId is provided
  if (isAutoSaveMode.value) {
    try {
      const result = await piecesStore.addFiring({
        piece_id: props.pieceId,
        cone: cone ? String(cone) : null,
        temperature_f: null,
        kiln_type: null,
        kiln_location: null,
        load_name: null,
        date: null,
        notes: null,
      })
      // Update the row with the returned ID
      newRow.id = result.id
      showAutoSaveToast('Firing added')
    } catch (error) {
      console.error('[FiringRowsEditor] Failed to save firing to database:', error)
      return // Don't add to UI if save failed
    }
  }

  const next = [...props.modelValue, newRow]
  emit('update:modelValue', next)
}
async function addRow() {
  const newRow = {
    id: null,
    cone: '',
    tempF: '',
    kilnType: '',
    kilnLocation: '',
    name: '',
    date: '',
    notes: '',
  }

  // Auto-save to database if pieceId is provided
  if (isAutoSaveMode.value) {
    try {
      const result = await piecesStore.addFiring({
        piece_id: props.pieceId,
        cone: null,
        temperature_f: null,
        kiln_type: null,
        kiln_location: null,
        load_name: null,
        date: null,
        notes: null,
      })
      // Update the row with the returned ID
      newRow.id = result.id
      showAutoSaveToast('Firing added')
    } catch (error) {
      console.error('[FiringRowsEditor] Failed to save firing to database:', error)
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
      await piecesStore.deleteFiring(rowToRemove.id)
      showAutoSaveToast('Firing removed')
    } catch (error) {
      console.error('[FiringRowsEditor] Failed to delete firing from database:', error)
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

      // Map field names to database column names
      switch (field) {
        case 'cone':
          payload.cone = value ? String(value) : null
          break
        case 'tempF':
          payload.temperature_f = value ? parseInt(value, 10) : null
          break
        case 'kilnType':
          payload.kiln_type = value || null
          break
        case 'kilnLocation':
          payload.kiln_location = value || null
          break
        case 'name':
          payload.load_name = value || null
          break
        case 'date':
          payload.date = value || null
          break
        case 'notes':
          payload.notes = value || null
          break
      }

      await piecesStore.updateFiring(currentRow.id, payload)
      showAutoSaveToast('Firing updated')
    } catch (error) {
      console.error('[FiringRowsEditor] Failed to update firing in database:', error)
      return // Don't update UI if save failed
    }
  }

  // Update local state
  const next = rowsValue.value.map((r, i) => (i === idx ? { ...r, [field]: value } : r))
  emit('update:modelValue', next)
}
</script>
