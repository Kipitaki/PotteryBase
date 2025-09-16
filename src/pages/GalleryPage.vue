<template>
  <q-page padding>
    <!-- Search -->
    <div class="row items-center q-mb-md">
      <q-input
        outlined
        dense
        v-model="search"
        debounce="200"
        placeholder="Search by glaze, notes, or title..."
        class="col-12 col-md-6"
      >
        <template #append>
          <q-icon name="search" />
        </template>
      </q-input>
    </div>

    <!-- Filter chips -->
    <div class="row q-gutter-xs q-mb-md">
      <q-chip
        v-for="s in STAGES"
        :key="s.value"
        clickable
        :color="activeStages.includes(s.value) ? 'primary' : 'grey-3'"
        :text-color="activeStages.includes(s.value) ? 'white' : 'black'"
        @click="toggleStage(s.value)"
        dense
      >
        {{ s.label }}
      </q-chip>
    </div>

    <!-- Grid -->
    <div v-if="filtered.length" class="row q-col-gutter-md">
      <div v-for="p in filtered" :key="p.id" class="col-12 col-sm-6 col-md-4 col-lg-3">
        <shelf-piece-card :piece="p" />
      </div>
    </div>
    <div v-else class="text-grey-7 text-center q-mt-xl">No pieces match your search.</div>
  </q-page>
</template>

<script setup>
import { ref, computed } from 'vue'
import { usePiecesStore } from 'src/stores/pieces'
import ShelfPieceCard from 'src/components/ShelfPieceCard.vue'

const search = ref('')
const activeStages = ref([])

const store = usePiecesStore()

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

/* ---------- Filtering ---------- */
const visible = computed(() => store.pieces.filter((p) => p.share !== 'private'))

const filtered = computed(() => {
  const q = search.value.toLowerCase()
  let result = visible.value

  // search filter
  if (q) {
    result = result.filter((p) => {
      return (
        (p.title || '').toLowerCase().includes(q) ||
        (p.notes || '').toLowerCase().includes(q) ||
        p.glazes.some((g) => (g.glazeName || '').toLowerCase().includes(q))
      )
    })
  }

  // stage chip filter
  if (activeStages.value.length) {
    result = result.filter((p) => {
      const stageKeys = Object.keys(p.stageDates || {}).filter((k) => p.stageDates[k])
      return stageKeys.some((s) => activeStages.value.includes(s))
    })
  }

  return result
})

function toggleStage(stage) {
  if (activeStages.value.includes(stage)) {
    activeStages.value = activeStages.value.filter((s) => s !== stage)
  } else {
    activeStages.value.push(stage)
  }
}
</script>

<style scoped>
.q-chip {
  cursor: pointer;
}
</style>
