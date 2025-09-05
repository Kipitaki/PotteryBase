<template>
  <section-card>
    <template #title>Stages</template>

    <q-list bordered separator class="rounded-borders">
      <q-item v-for="s in stages" :key="s.value" class="stage-row">
        <q-item-section avatar>
          <!-- Controlled by parent via props; we emit changes immediately -->
          <q-checkbox
            :model-value="Boolean(stageDates[s.value])"
            color="primary"
            @update:model-value="(val) => onToggle(s.value, val)"
          />
        </q-item-section>

        <q-item-section>
          <q-item-label>{{ s.label }}</q-item-label>
          <q-item-label caption>Optional date</q-item-label>
        </q-item-section>

        <q-item-section side style="min-width: 190px">
          <q-input
            :model-value="stageDates[s.value]"
            type="date"
            dense
            hide-bottom-space
            style="width: 180px"
            @update:model-value="(val) => onDateChange(s.value, val)"
          />
        </q-item-section>
      </q-item>
    </q-list>

    <div class="row q-col-gutter-sm q-mt-sm">
      <div class="col-12 col-sm-6">
        <q-input
          :model-value="stageLocation"
          label="Location (optional)"
          dense
          hide-bottom-space
          @update:model-value="(val) => emit('update:stageLocation', val)"
        />
      </div>
    </div>
  </section-card>
</template>

<script setup>
import SectionCard from './SectionCard.vue'

const props = defineProps({
  /* v-models from parent (camelCase!) */
  stageDates: { type: Object, required: true },
  stageLocation: { type: String, default: '' },
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
const emit = defineEmits(['update:stageDates', 'update:stageLocation'])

const todayISO = () => new Date().toISOString().slice(0, 10)

/* Toggle checkbox -> set/clear date in a cloned object, then emit */
function onToggle(key, val) {
  const next = { ...props.stageDates }
  if (val) {
    if (!next[key]) next[key] = todayISO()
  } else {
    next[key] = ''
  }
  emit('update:stageDates', next)
}

/* Date picker changes -> emit new object; empty string unchecks */
function onDateChange(key, val) {
  const next = { ...props.stageDates }
  next[key] = val || '' // ensure '' when cleared
  emit('update:stageDates', next)
}
</script>

<style scoped>
.rounded-borders {
  border-radius: 12px;
}
.stage-row {
  align-items: center;
}
</style>
