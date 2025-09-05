<template>
  <q-page padding>
    <!-- Top Navigation -->

    <div class="row items-center justify-between q-mb-md">
      <div class="text-h5">Shelf (Kanban)</div>
      <div class="text-caption text-grey-7">Drag cards between rows to update stage</div>
    </div>

    <!-- Debug -->
    <pre>Pieces: {{ safePieces.length }}</pre>

    <!-- Lanes -->
    <div v-for="lane in lanes" :key="lane.key" class="q-mb-lg">
      <div class="row items-center q-mb-sm">
        <div class="text-subtitle1">{{ lane.label }}</div>
        <q-badge outline color="grey-7" class="q-ml-sm">{{ lane.list.length }}</q-badge>
      </div>

      <div class="lane-scroll" :class="{ 'lane-empty': !lane.list.length }">
        <draggable
          class="lane-cards"
          :list="lane.list"
          item-key="id"
          :group="{ name: 'pieces' }"
          :animation="180"
          ghost-class="drag-ghost"
          @add="(evt) => onCardDropped(evt, lane.key)"
        >
          <template #item="{ element }">
            <shelf-piece-card :piece="element" :subtitle="latestLabel(element)" />
          </template>

          <template #footer v-if="!lane.list.length">
            <div class="lane-placeholder">Drop here</div>
          </template>
        </draggable>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import draggable from 'vuedraggable'
import { reactive, onMounted, watch, computed } from 'vue'
import { usePiecesStore } from 'src/stores/pieces'
import ShelfPieceCard from 'src/components/ShelfPieceCard.vue'

/* ---------- Stage definitions ---------- */
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
const stageOrder = STAGES.map((s) => s.value)
const stageLabelMap = Object.fromEntries(STAGES.map((s) => [s.value, s.label]))

/* ---------- Store ---------- */
const piecesStore = usePiecesStore()
const safePieces = computed(() => piecesStore.all?.value ?? [])

/* ---------- Reactive lanes ---------- */
const lanes = reactive([])

/* ---------- Helpers ---------- */
function buildStageDates(histories = []) {
  const out = {}
  for (const h of histories) {
    out[h.stage] = h.date
  }
  return out
}

function latestStageKey(stageDates = {}) {
  for (let i = stageOrder.length - 1; i >= 0; i--) {
    const key = stageOrder[i]
    if (stageDates[key]) return key
  }
  return null
}

function rebuildLanes() {
  const map = Object.fromEntries(stageOrder.map((k) => [k, []]))

  for (const p of safePieces.value) {
    const stageDates = buildStageDates(p.piece_stage_histories)
    const key = latestStageKey(stageDates)
    if (key) {
      map[key].push({ ...p, stageDates }) // attach derived stageDates
    }
  }

  const out = stageOrder.map((k) => ({
    key: k,
    label: stageLabelMap[k],
    list: map[k],
  }))

  lanes.splice(0, lanes.length, ...out)
}

/* ---------- Lifecycle ---------- */
onMounted(() => {
  rebuildLanes()
})
watch(safePieces, () => {
  rebuildLanes()
})

/* ---------- Drag handler ---------- */
async function onCardDropped(evt, targetStage) {
  const moved = evt.item?.__draggable_context?.element
  if (!moved || !moved.id) return

  const now = new Date().toISOString()
  await piecesStore.addStage({
    piece_id: moved.id,
    stage: targetStage,
    date: now,
  })
}

/* ---------- Card subtitle helper ---------- */
function latestLabel(p) {
  const key = latestStageKey(p.stageDates)
  if (!key) return ''
  const d = p.stageDates?.[key]
  if (!d) return stageLabelMap[key]

  const date = new Date(d)
  const mm = String(date.getMonth() + 1).padStart(2, '0')
  const dd = String(date.getDate()).padStart(2, '0')
  const yy = String(date.getFullYear()).slice(-2)

  return `${stageLabelMap[key]} • ${mm}/${dd}/${yy}`
}
</script>

<style scoped>
.lane-cards {
  display: flex;
  flex-wrap: wrap; /* wrap to next row if needed */
  gap: 8px; /* spacing between cards */
  align-items: flex-start;
}
</style>
