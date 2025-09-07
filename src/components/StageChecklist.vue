<template>
  <section-card>
    <template #title>
      <div class="column">
        <span class="text-subtitle1">Stages</span>
        <span class="text-caption text-grey-6">
          {{ unitDisplay }}
        </span>
      </div>
    </template>

    <q-list bordered separator class="rounded-borders">
      <q-item v-for="s in stages" :key="s.value" class="stage-row">
        <!-- Checkbox or Pill -->
        <q-item-section avatar style="min-width: 60px">
          <q-checkbox
            v-if="!stageDates[s.value]"
            :model-value="false"
            color="primary"
            @update:model-value="(val) => onToggle(s.value, val)"
          />
          <q-chip
            v-else
            color="primary"
            text-color="white"
            size="md"
            clickable
            @click="onToggle(s.value, false)"
          >
            {{ s.label }}
          </q-chip>
        </q-item-section>

        <!-- Label + dimensions -->
        <q-item-section style="flex: 1">
          <q-item-label v-if="!stageDates[s.value]">{{ s.label }}</q-item-label>
          <q-item-label caption>
            <div
              v-if="stageDims[s.value]"
              class="dimensions-display"
              @click="openDimsForm(s.value)"
            >
              <div>
                📏 {{ profileStore.toLengthDisplay(stageDims[s.value].length) }}×{{
                  profileStore.toLengthDisplay(stageDims[s.value].width)
                }}×{{ profileStore.toLengthDisplay(stageDims[s.value].height) }}
              </div>
              <div v-if="stageDims[s.value].weight">
                ⚖️ {{ profileStore.toWeightDisplay(stageDims[s.value].weight) }}
              </div>
            </div>
            <q-btn
              v-else
              flat
              size="sm"
              dense
              color="primary"
              label="Enter Dimensions"
              @click="openDimsForm(s.value)"
            />
          </q-item-label>
        </q-item-section>

        <!-- Date + Location -->
        <q-item-section side style="min-width: 120px">
          <div class="column">
            <span
              v-if="stageDates[s.value] && editingDate !== s.value"
              class="date-display"
              @click="startEditingDate(s.value)"
            >
              {{ formatDate(stageDates[s.value]) }}
            </span>
            <q-input
              v-else
              :model-value="stageDates[s.value]"
              type="date"
              dense
              hide-bottom-space
              style="width: 130px"
              @update:model-value="(val) => onDateChange(s.value, val)"
              @blur="stopEditingDate"
            />
            <div v-if="stageDims[s.value]?.location" class="text-caption text-grey-6 q-mt-xs">
              📍 {{ stageDims[s.value].location }}
            </div>
          </div>
        </q-item-section>
      </q-item>
    </q-list>

    <!-- Dialog -->
    <q-dialog v-model="dimsDialog.open">
      <q-card style="min-width: 400px">
        <q-card-section>
          <div class="text-h6">Dimensions for {{ dimsDialog.stage }}</div>
        </q-card-section>
        <q-card-section class="row q-col-gutter-sm">
          <q-input
            v-model.number="dimsDialog.form.length"
            :label="`Length (${lengthUnit})`"
            type="number"
            dense
            class="col-3"
          />
          <q-input
            v-model.number="dimsDialog.form.width"
            :label="`Width (${lengthUnit})`"
            type="number"
            dense
            class="col-3"
          />
          <q-input
            v-model.number="dimsDialog.form.height"
            :label="`Height (${lengthUnit})`"
            type="number"
            dense
            class="col-3"
          />
          <q-input
            v-model.number="dimsDialog.form.weight"
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

const props = defineProps({
  stageDates: { type: Object, required: true },
  stageDims: { type: Object, default: () => ({}) },
  isHydrating: { type: Boolean, default: false },
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
const emit = defineEmits(['update:stageDates', 'update:stageDims'])

const profileStore = useProfileStore()
const editingDate = ref(null)

const unitDisplay = computed(() =>
  profileStore.isMetric.value ? 'Metric (cm/g)' : 'Imperial (in/lb)',
)
const lengthUnit = computed(() => (profileStore.isMetric.value ? 'cm' : 'in'))
const weightUnit = computed(() => (profileStore.isMetric.value ? 'g' : 'lb'))

function onToggle(key, val) {
  if (props.isHydrating) return
  const next = { ...props.stageDates }
  next[key] = val ? new Date().toISOString().slice(0, 10) : ''
  emit('update:stageDates', next)
}

function onDateChange(key, val) {
  if (props.isHydrating) return
  const next = { ...props.stageDates }
  next[key] = val || ''
  emit('update:stageDates', next)
}

function formatDate(dateString) {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString()
}

function startEditingDate(stage) {
  editingDate.value = stage
}

function stopEditingDate() {
  editingDate.value = null
}

const dimsDialog = ref({
  open: false,
  stage: '',
  form: { length: '', width: '', height: '', weight: '', location: '' },
})

function openDimsForm(stage) {
  const dims = props.stageDims[stage]
  dimsDialog.value.form = dims
    ? {
        length: profileStore.toLengthInput(dims.length),
        width: profileStore.toLengthInput(dims.width),
        height: profileStore.toLengthInput(dims.height),
        weight: profileStore.toWeightInput(dims.weight),
        location: dims.location || '',
      }
    : { length: '', width: '', height: '', weight: '', location: '' }
  dimsDialog.value.stage = stage
  dimsDialog.value.open = true
}

function saveDims() {
  const next = { ...props.stageDims }
  next[dimsDialog.value.stage] = {
    length: profileStore.fromLengthInput(dimsDialog.value.form.length),
    width: profileStore.fromLengthInput(dimsDialog.value.form.width),
    height: profileStore.fromLengthInput(dimsDialog.value.form.height),
    weight: profileStore.fromWeightInput(dimsDialog.value.form.weight),
    location: dimsDialog.value.form.location,
  }
  emit('update:stageDims', next)
}
</script>

<style scoped>
.rounded-borders {
  border-radius: 12px;
}
.stage-row {
  align-items: center;
}
.dimensions-display {
  cursor: pointer;
  transition: opacity 0.2s;
}
.dimensions-display:hover {
  opacity: 0.7;
}
.date-display {
  cursor: pointer;
  transition: opacity 0.2s;
  font-size: 0.9rem;
}
.date-display:hover {
  opacity: 0.7;
}
</style>
