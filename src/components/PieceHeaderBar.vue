<template>
  <div class="row q-col-gutter-md items-start q-mb-xs">
    <!-- Title -->
    <div class="col-12 col-md-4">
      <div class="row items-center q-gutter-xs q-mb-xs">
        <span class="text-caption text-grey-7">Piece Title</span>
      </div>
      <div class="row q-gutter-sm items-end">
        <div class="col">
          <q-input
            v-model="localTitle"
            dense
            hide-bottom-space
            placeholder="Enter piece title..."
          />
        </div>
        <div class="col-auto">
          <q-btn
            flat
            dense
            color="primary"
            icon="auto_awesome"
            label="Generate Name"
            @click="generateName"
            size="sm"
            no-caps
          />
        </div>
      </div>
    </div>

    <!-- Share -->
    <div class="col-12 col-md-6">
      <div class="row items-center q-gutter-xs q-mb-xs">
        <span class="text-caption text-grey-7">Share Settings</span>
      </div>
      <q-select
        v-model="localShare"
        :options="shareOptions"
        dense
        emit-value
        map-options
        hide-bottom-space
        placeholder="Select sharing level..."
      />
    </div>

    <!-- Latest stage -->
    <div class="col-12 col-md-2">
      <div class="q-pa-xs bg-white rounded-borders row items-center">
        <q-icon name="flag" size="18px" class="q-mr-sm" />
        <div class="text-subtitle2">Latest:</div>
        <q-chip v-if="latest?.key" color="primary" text-color="white" size="sm" class="q-ml-sm">
          {{ latestLabel }}
        </q-chip>
        <div v-if="latest?.date" class="text-caption q-ml-sm">on {{ fmtDate(latest.date) }}</div>
        <div v-else class="text-caption q-ml-sm">none</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, watch, toRefs, computed } from 'vue'
import { useNameGeneratorStore } from 'src/stores/nameGenerator'

const props = defineProps({
  title: { type: String, default: '' }, // v-model:title
  share: { type: String, default: 'private' }, // v-model:share
  latest: { type: Object, default: null }, // { key, date }
  stageLabelMap: { type: Object, default: () => ({}) },
})
const emit = defineEmits(['update:title', 'update:share'])

const nameGen = useNameGeneratorStore()

const state = reactive({
  localTitle: props.title ?? '',
  localShare: props.share ?? 'private',
})

watch(
  () => props.title,
  (v) => {
    state.localTitle = v ?? ''
  },
)
watch(
  () => props.share,
  (v) => {
    state.localShare = v ?? 'private'
  },
)

watch(
  () => state.localTitle,
  (v) => emit('update:title', v),
)
watch(
  () => state.localShare,
  (v) => emit('update:share', v),
)

const { localTitle, localShare } = toRefs(state)

const shareOptions = [
  { label: 'Public (online searchable)', value: 'Public' },
  { label: 'Community (all community)', value: 'Community' },
  { label: 'Community Group (your Groups only)', value: 'Community_group' },
  { label: 'Private (only you)', value: 'Private' },
]

const latestLabel = computed(() =>
  props.latest?.key ? props.stageLabelMap?.[props.latest.key] || props.latest.key : '',
)

function generateName() {
  const newName = nameGen.getRandomName()
  state.localTitle = newName
}

function fmtDate(iso) {
  try {
    return new Date(iso).toLocaleDateString()
  } catch {
    return iso
  }
}
</script>

<style scoped>
.rounded-borders {
  border-radius: 12px;
}
</style>
