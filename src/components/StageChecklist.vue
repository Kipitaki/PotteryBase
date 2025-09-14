<template>
  <section-card>
    <!-- Title -->
    <template #title>
      <div class="column">
        <span class="text-subtitle1">Stages</span>
        <span class="text-caption text-grey-6">{{ unitDisplay }}</span>
      </div>
    </template>

    <!-- Pills for unused stages -->
    <div class="row items-center q-gutter-xs q-mb-xs">
      <q-chip
        v-for="s in unusedStages"
        :key="s.value"
        dense
        clickable
        outline
        color="grey-6"
        @click="addStageRow(s)"
      >
        {{ s.label }}
      </q-chip>
    </div>

    <!-- No stages yet -->
    <div v-if="!rowsValue.length" class="text-grey-7 q-mb-xs">No stages yet.</div>

    <!-- Stage rows -->
    <q-list bordered separator class="rounded-borders">
      <q-item
        v-for="row in sortedRows"
        :key="row.id ?? `local-${row.stage}`"
        class="stage-row compact-row"
      >
        <!-- Stage label -->
        <q-item-section avatar style="min-width: 80px; padding-right: 2px">
          <q-chip dense color="primary" text-color="white">
            {{ getStageLabel(row.stage) }}
          </q-chip>
        </q-item-section>

        <!-- Dimensions -->
        <q-item-section style="flex: 1; padding-left: 2px">
          <div
            v-if="row.length_cm || row.width_cm || row.height_cm || row.weight_g"
            class="dimensions-display"
            @click="openDimsForm(row)"
          >
            <div class="dimensions-line">
              📏 {{ formatDimensions(row.length_cm, row.width_cm, row.height_cm) }}
            </div>
            <div v-if="row.weight_g" class="weight-line">
              ⚖️ {{ profileStore.toWeightDisplay(row.weight_g) }}
            </div>
          </div>
          <div v-else class="dimensions-display" @click="openDimsForm(row)">
            <q-btn flat size="sm" dense color="primary" label="Enter Dimensions" />
          </div>
        </q-item-section>

        <!-- Date and Location -->
        <q-item-section side style="min-width: 120px; padding-left: 8px">
          <div class="column items-end">
            <!-- Date -->
            <span
              v-if="row.date && editingDate !== row.stage"
              class="date-display"
              @click="startEditingDate(row.stage)"
            >
              {{ formatDate(row.date) }}
            </span>
            <q-input
              v-else
              :model-value="row.date"
              type="date"
              dense
              hide-bottom-space
              style="width: 130px"
              @update:model-value="(val) => onDateChange(row, val)"
              @blur="stopEditingDate"
            />

            <!-- Location -->
            <div v-if="row.location" class="location-display text-grey-6">
              📍 {{ row.location }}
            </div>
          </div>
        </q-item-section>

        <!-- Remove -->
        <q-item-section side>
          <q-btn flat dense round icon="close" color="negative" @click="remove(row)" />
        </q-item-section>
      </q-item>
    </q-list>

    <!-- Dimensions Dialog -->
    <q-dialog v-model="dimsDialog.open">
      <q-card style="min-width: 400px">
        <q-card-section>
          <div class="text-h6">Dimensions for {{ getStageLabel(dimsDialog.stage) }}</div>
        </q-card-section>
        <q-card-section class="row q-col-gutter-sm">
          <q-input
            v-model.number="dimsDialog.form.length_cm"
            :label="`Length (${lengthUnit})`"
            type="number"
            dense
            class="col-3"
          />
          <q-input
            v-model.number="dimsDialog.form.width_cm"
            :label="`Width (${lengthUnit})`"
            type="number"
            dense
            class="col-3"
          />
          <q-input
            v-model.number="dimsDialog.form.height_cm"
            :label="`Height (${lengthUnit})`"
            type="number"
            dense
            class="col-3"
          />
          <q-input
            v-model.number="dimsDialog.form.weight_g"
            :label="`Weight (${weightUnit})`"
            type="number"
            dense
            class="col-3"
          />
          <q-input v-model="dimsDialog.form.location" label="Location" dense class="col-12" />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="primary" label="Save" @click="saveDims" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </section-card>
</template>

<script setup>
import { ref, computed } from 'vue'
import SectionCard from './SectionCard.vue'
import { useProfileStore } from 'src/stores/profile'
import { usePiecesStore } from 'src/stores/pieces'

const props = defineProps({
  modelValue: { type: Array, default: () => [] }, // [{ id, stage, date, length_cm, width_cm, height_cm, weight_g, location }]
  pieceId: { type: [Number, null], default: null },
  stages: {
    type: Array,
    default: () => [
      { label: 'Lump', value: 'lump' },
      { label: 'Formed', value: 'formed' },
      { label: 'Trimmed', value: 'trimmed' },
      { label: 'Bisque', value: 'bisque' },
      { label: 'Glazed', value: 'glazed' },
      { label: 'Fired', value: 'fired' },
      { label: 'Sold or Posted', value: 'sold_posted' },
      { label: 'Sold or Kept', value: 'sold_kept' },
    ],
  },
})
const emit = defineEmits(['update:modelValue'])

const profileStore = useProfileStore()
const piecesStore = usePiecesStore()

const rowsValue = computed({
  get: () => props.modelValue || [],
  set: (val) => emit('update:modelValue', val),
})

/* Units */
const unitDisplay = computed(() =>
  profileStore.isMetric.value ? 'Metric (cm/g)' : 'Imperial (in/lb)',
)
const lengthUnit = computed(() => (profileStore.isMetric.value ? 'cm' : 'in'))
const weightUnit = computed(() => (profileStore.isMetric.value ? 'g' : 'lb'))

/* Stage pills */
const unusedStages = computed(() =>
  props.stages.filter((s) => !rowsValue.value.some((r) => r.stage === s.value)),
)

/* Sort rows in stage order */
const sortedRows = computed(() => {
  const order = props.stages.map((s) => s.value)
  return [...rowsValue.value].sort((a, b) => order.indexOf(a.stage) - order.indexOf(b.stage))
})

/* Add stage row */
async function addStageRow(stageDef) {
  try {
    const result = await piecesStore.addStage({
      piece_id: props.pieceId,
      stage: stageDef.value,
      date: new Date().toISOString().slice(0, 10),
    })
    rowsValue.value = [...rowsValue.value, result]
  } catch (err) {
    console.error('[StageCard] Failed to add stage:', err)
  }
}

/* Update date */
async function onDateChange(row, val) {
  try {
    const updated = await piecesStore.updateStage(row.id, { date: val })
    rowsValue.value = rowsValue.value.map((r) =>
      r.id === row.id ? { ...r, date: updated.date } : r,
    )
  } catch (err) {
    console.error('[StageCard] Failed to update date:', err)
  }
}

/* Remove */
async function remove(row) {
  try {
    await piecesStore.deleteStage(row.id)
    rowsValue.value = rowsValue.value.filter((r) => r.id !== row.id)
  } catch (err) {
    console.error('[StageCard] Failed to delete stage:', err)
  }
}

/* Dimensions dialog */
const dimsDialog = ref({
  open: false,
  stage: '',
  rowId: null,
  form: { length_cm: '', width_cm: '', height_cm: '', weight_g: '', location: '' },
})

function openDimsForm(row) {
  dimsDialog.value = {
    open: true,
    stage: row.stage,
    rowId: row.id,
    form: {
      length_cm: profileStore.toLengthInput(row.length_cm),
      width_cm: profileStore.toLengthInput(row.width_cm),
      height_cm: profileStore.toLengthInput(row.height_cm),
      weight_g: profileStore.toWeightInput(row.weight_g),
      location: row.location || '',
    },
  }
}

async function saveDims() {
  try {
    const form = dimsDialog.value.form
    const changes = {
      length_cm: profileStore.fromLengthInput(form.length_cm),
      width_cm: profileStore.fromLengthInput(form.width_cm),
      height_cm: profileStore.fromLengthInput(form.height_cm),
      weight_g: profileStore.fromWeightInput(form.weight_g),
      location: form.location || null,
    }
    const updated = await piecesStore.updateStage(dimsDialog.value.rowId, changes)
    rowsValue.value = rowsValue.value.map((r) => (r.id === updated.id ? { ...r, ...updated } : r))
  } catch (err) {
    console.error('[StageCard] Failed to save dims:', err)
  }
}

/* Date editing state */
const editingDate = ref(null)
function startEditingDate(stage) {
  editingDate.value = stage
}
function stopEditingDate() {
  editingDate.value = null
}

/* Helpers */
function formatDate(dateString) {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString()
}
function getStageLabel(stageVal) {
  const s = props.stages.find((s) => s.value === stageVal)
  return s ? s.label : stageVal
}
function formatDimensions(length, width, height) {
  const parts = []
  const unit = profileStore.isMetric.value ? 'cm' : 'in'

  if (length) {
    const val = profileStore.isMetric.value ? length : length / 2.54
    parts.push(val.toFixed(2))
  }
  if (width) {
    const val = profileStore.isMetric.value ? width : width / 2.54
    parts.push(val.toFixed(2))
  }
  if (height) {
    const val = profileStore.isMetric.value ? height : height / 2.54
    parts.push(val.toFixed(2))
  }

  return parts.length > 0 ? `${parts.join('x')} ${unit}` : ''
}
</script>

<style scoped>
.rounded-borders {
  border-radius: 12px;
}
.stage-row {
  align-items: center;
}
.compact-row {
  padding: 4px 12px;
  min-height: 40px;
}
.dimensions-display {
  cursor: pointer;
  transition: opacity 0.2s;
  line-height: 1.1;
}
.dimensions-display:hover {
  opacity: 0.7;
}
.dimensions-line {
  margin-bottom: 1px;
  font-size: 0.75rem;
}
.weight-line {
  font-size: 0.75rem;
  color: #666;
}
.date-display {
  cursor: pointer;
  transition: opacity 0.2s;
  font-size: 0.9rem;
}
.date-display:hover {
  opacity: 0.7;
}
.location-display {
  font-size: 0.75rem;
  margin-top: 0px;
  max-width: 120px;
  text-align: right;
  word-break: break-word;
  line-height: 1;
}
</style>
