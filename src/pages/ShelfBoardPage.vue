<template>
  <q-page padding>
    <!-- Header -->
    <div class="row items-center justify-between q-mb-md">
      <div class="text-h5">My Shelf (Kanban)</div>
      <div class="text-caption text-grey-7">Drag cards between rows to update stage</div>
    </div>

    <!-- Stage Lanes -->
    <div v-for="lane in lanes" :key="lane.key" class="q-mb-lg">
      <!-- Lane Header -->
      <div class="row items-center q-mb-sm">
        <div class="text-subtitle1">{{ lane.label }}</div>
        <q-badge outline color="grey-7" class="q-ml-sm">
          {{ lane.list.length }}
        </q-badge>
      </div>

      <!-- Cards -->
      <draggable
        v-model="lane.list"
        :group="{ name: 'pieces', pull: true, put: true }"
        :data-stage="lane.key"
        item-key="id"
        class="lane-scroll"
        :animation="180"
        ghost-class="drag-ghost"
        :delay="200"
        :delay-on-touch-only="true"
        :touch-start-threshold="6"
        @start="(evt) => onDragStart(evt, lane.key)"
        @end="(evt) => onDragEnd(evt, lane.key)"
        @change="(evt) => onDragChange(evt, lane.key)"
      >
        <template #item="{ element }">
          <div class="lane-card" :data-piece-id="element.id">
            <shelf-piece-card :piece="element" :subtitle="latestLabel(element)" />
          </div>
        </template>

        <template #footer v-if="!lane.list.length">
          <div class="lane-placeholder">Drop here</div>
        </template>
      </draggable>
    </div>
  </q-page>
</template>

<script setup>
import draggable from 'vuedraggable'
import { reactive, watch, computed } from 'vue'
import { usePiecesStore } from 'src/stores/pieces'
import ShelfPieceCard from 'src/components/ShelfPieceCard.vue'
import { nhost } from 'boot/nhost'

/* ---------- Stage definitions ---------- */
const STAGES = [
  { label: 'Lump', value: 'lump' },
  { label: 'Formed', value: 'formed' },
  { label: 'Trimmed', value: 'trimmed' },
  { label: 'Bisque', value: 'bisque' },
  { label: 'Glazed', value: 'glazed' },
  { label: 'Fired', value: 'fired' },
  { label: 'Archived', value: 'archived' },
  { label: 'Failed', value: 'failed' },
]
const stageOrder = STAGES.map((s) => s.value)
const stageLabelMap = Object.fromEntries(STAGES.map((s) => [s.value, s.label]))

/* ---------- Store ---------- */
const piecesStore = usePiecesStore()
const currentUserId = nhost.auth.getUser()?.id || null

// Only show the logged-in user's pieces
const safePieces = computed(() => {
  const all = piecesStore.all?.value ?? []
  const filtered = all.filter((p) => p.owner_id === currentUserId)
  return filtered
})

/* ---------- Reactive lanes ---------- */
const lanes = reactive(
  stageOrder.map((k) => ({
    key: k,
    label: stageLabelMap[k],
    list: [],
  })),
)

function buildStageDates(histories = []) {
  return histories.reduce((acc, h) => {
    acc[h.stage] = h.date
    return acc
  }, {})
}
function latestStageKey(stageDates = {}) {
  for (let i = stageOrder.length - 1; i >= 0; i--) {
    if (stageDates[stageOrder[i]]) return stageOrder[i]
  }
  return null
}

/* ---------- Distribute pieces into lanes ---------- */
watch(
  safePieces,
  (pieces) => {
    for (const lane of lanes) lane.list.splice(0)

    for (const p of pieces) {
      const stageDates = buildStageDates(p.piece_stage_histories || [])
      const key = latestStageKey(stageDates) || 'lump'
      const lane = lanes.find((l) => l.key === key)
      if (lane) {
        lane.list.push({ ...p, stageDates })
      }
    }
  },
  { immediate: true },
)

/* ---------- Drag handlers ---------- */
let dragSourceStage = null

function onDragStart(evt, fromStage) {
  dragSourceStage = fromStage
}

function onDragEnd() {
  // Drag end handler - no action needed
}

function onDragChange(evt, targetStage) {
  // Check if a piece was added to this lane (moved from another lane)
  if (evt.added && evt.added.element && dragSourceStage && dragSourceStage !== targetStage) {
    const pieceId = evt.added.element.id
    addStageHistory(pieceId, targetStage)
  }
}

async function addStageHistory(pieceId, targetStage) {
  if (!pieceId) {
    return
  }

  // Find the piece to check its existing stage history
  const piece = safePieces.value.find((p) => p.id === Number(pieceId))
  if (!piece) {
    return
  }

  // Check if this stage already exists in the piece's history
  const existingStage = piece.piece_stage_histories?.find((h) => h.stage === targetStage)
  if (existingStage) {
    return
  }

  const today = new Date().toISOString().slice(0, 10)
  const payload = { piece_id: Number(pieceId), stage: targetStage, date: today }

  try {
    await piecesStore.addStage(payload)
  } catch {
    // Silent fail - stage history creation failed
  } finally {
    // Reset drag tracking
    dragSourceStage = null
  }
}

/* ---------- Card subtitle helper ---------- */
function latestLabel(p) {
  const key = latestStageKey(p.stageDates)
  if (!key) return ''
  const d = p.stageDates?.[key]
  if (!d) return stageLabelMap[key]
  return `${stageLabelMap[key]} • ${new Date(d).toLocaleDateString()}`
}
</script>

<style scoped>
.lane-scroll {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  min-height: 60px;
  padding: 6px;
  background: #fafafa;
  border: 1px dashed #ddd;
  border-radius: 8px;
}

.lane-card {
  background: white;
  border-radius: 6px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  padding: 4px;
  min-width: 160px;
}

.lane-placeholder {
  padding: 12px;
  color: #aaa;
  font-style: italic;
}
</style>
