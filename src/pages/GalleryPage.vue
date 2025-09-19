<template>
  <q-page padding>
    <!-- Header -->
    <div class="row items-center justify-between q-mb-lg">
      <div>
        <div class="text-h4 text-weight-bold">Community Gallery</div>
        <div class="text-body2 text-grey-6">Discover pottery pieces from you and the community</div>
      </div>

      <!-- Like Toggle (fire button) -->
      <q-btn
        round
        flat
        size="md"
        :icon="viewMode === 'liked' ? 'whatshot' : 'whatshot_outline'"
        :color="viewMode === 'liked' ? 'red' : 'grey'"
        @click="toggleLikedView"
      >
        <q-tooltip>
          {{ viewMode === 'liked' ? 'Showing My Likes' : 'Show My Likes' }}
        </q-tooltip>
      </q-btn>
    </div>

    <!-- Filters -->
    <q-card class="q-mb-lg" flat bordered>
      <q-card-section>
        <div class="row items-center q-mb-md">
          <q-icon name="tune" class="q-mr-sm" />
          <div class="text-h6">Filters</div>

          <!-- Global AND/OR Toggle -->
          <q-chip
            clickable
            :color="searchOperator === 'AND' ? 'green' : 'orange'"
            text-color="white"
            size="md"
            class="q-ml-md text-bold"
            @click="toggleSearchOperator"
          >
            {{ searchOperator }}
          </q-chip>

          <q-space />
          <q-btn
            flat
            dense
            color="grey-7"
            icon="clear"
            label="Clear All"
            @click="clearAllFilters"
            :disable="!hasActiveFilters"
          />
        </div>

        <div class="row q-col-gutter-md">
          <!-- Glaze Filter -->
          <div class="col-12 col-md-4">
            <q-select
              v-model="selectedGlazes"
              :options="glazeOptions"
              option-label="name"
              option-value="id"
              multiple
              use-chips
              label="Glazes"
              outlined
              dense
              clearable
            >
              <template #prepend><q-icon name="palette" /></template>
            </q-select>
          </div>

          <!-- Clay Filter -->
          <div class="col-12 col-md-4">
            <q-select
              v-model="selectedClays"
              :options="clayOptions"
              option-label="name"
              option-value="id"
              multiple
              use-chips
              label="Clay Bodies"
              outlined
              dense
              clearable
            >
              <template #prepend><q-icon name="terrain" /></template>
            </q-select>
          </div>

          <!-- Firing Filter -->
          <div class="col-12 col-md-4">
            <q-select
              v-model="selectedFirings"
              :options="firingOptions"
              option-label="label"
              option-value="cone"
              multiple
              use-chips
              label="Firing Cones"
              outlined
              dense
              clearable
            >
              <template #prepend><q-icon name="local_fire_department" /></template>
            </q-select>
          </div>
        </div>
      </q-card-section>
    </q-card>

    <!-- Results Summary -->
    <div class="row items-center q-mb-md">
      <div class="text-body1">
        <strong>{{ filteredPieces.length }}</strong> pieces found
        <template v-if="hasActiveFilters">
          (filtered from {{ allVisiblePieces.length }} total)
        </template>
      </div>
      <q-space />
      <!-- Sort Options -->
      <q-select
        v-model="sortBy"
        :options="sortOptions"
        option-label="label"
        option-value="value"
        dense
        outlined
        label="Sort by"
        style="min-width: 150px"
      />
    </div>

    <!-- Gallery Grid -->
    <div v-if="sortedPieces.length" class="row q-col-gutter-md">
      <div v-for="piece in sortedPieces" :key="piece.id" class="col-12 col-sm-6 col-md-4 col-lg-3">
        <shelf-piece-card :piece="piece" />
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center q-mt-xl">
      <q-icon name="search_off" size="80px" color="grey-5" />
      <div class="text-h6 text-grey-6 q-mt-md">
        <template v-if="hasActiveFilters">No pieces match your filters</template>
        <template v-else-if="viewMode === 'liked'">You haven't liked any pieces yet</template>
        <template v-else>No pieces in the gallery yet</template>
      </div>
      <div class="text-body2 text-grey-7 q-mt-sm">
        <template v-if="hasActiveFilters">Try adjusting or clearing filters</template>
        <template v-else-if="viewMode === 'liked'">Like some pieces to see them here!</template>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { ref, computed } from 'vue'
import { usePiecesStore } from 'src/stores/pieces'
import { nhost } from 'boot/nhost'
import ShelfPieceCard from 'src/components/ShelfPieceCard.vue'

const store = usePiecesStore()

// Reactive state
const viewMode = ref('all') // all by default
const selectedGlazes = ref([])
const selectedClays = ref([])
const selectedFirings = ref([])
const sortBy = ref({ label: 'Newest First', value: 'newest' })
const searchOperator = ref('AND') // global AND/OR toggle

// Sorting options
const sortOptions = [
  { label: 'Newest First', value: 'newest' },
  { label: 'Oldest First', value: 'oldest' },
  { label: 'Most Liked', value: 'likes' },
  { label: 'Title A-Z', value: 'title_asc' },
  { label: 'Title Z-A', value: 'title_desc' },
]

// All visible pieces (exclude private, include yours + community)
const allVisiblePieces = computed(() => {
  const pieces = Array.isArray(store.allArray.value) ? store.allArray.value : []
  return pieces.filter((p) => (p.visibility || '').toLowerCase() !== 'private')
})

// Filtering logic with AND/OR operator
const filteredPieces = computed(() => {
  let result = [...allVisiblePieces.value]

  if (viewMode.value === 'liked') {
    const user = nhost.auth.getUser()
    if (!user?.id) return []
    result = result.filter((piece) => store.isLikedByUser(piece.id))
  }

  if (
    !selectedGlazes.value.length &&
    !selectedClays.value.length &&
    !selectedFirings.value.length
  ) {
    return result
  }

  return result.filter((piece) => {
    const pieceGlazeIds = piece.piece_glazes?.map((pg) => pg.glaze?.id) || []
    const pieceClayIds = piece.piece_clays?.map((pc) => pc.clay_body?.id) || []
    const pieceCones = piece.piece_firings?.map((pf) => pf.cone) || []

    const glazeMatch = selectedGlazes.value.some((g) => pieceGlazeIds.includes(g.id))
    const clayMatch = selectedClays.value.some((c) => pieceClayIds.includes(c.id))
    const firingMatch = selectedFirings.value.some((f) => pieceCones.includes(f.cone))

    if (searchOperator.value === 'AND') {
      return (
        (!selectedGlazes.value.length || glazeMatch) &&
        (!selectedClays.value.length || clayMatch) &&
        (!selectedFirings.value.length || firingMatch)
      )
    } else {
      return glazeMatch || clayMatch || firingMatch
    }
  })
})

// Sorting
const sortedPieces = computed(() => {
  const pieces = [...filteredPieces.value]
  switch (sortBy.value.value) {
    case 'oldest':
      return pieces.sort((a, b) => new Date(a.created_at) - new Date(b.created_at))
    case 'likes':
      return pieces.sort(
        (a, b) =>
          (b.piece_likes_aggregate?.aggregate?.count || 0) -
          (a.piece_likes_aggregate?.aggregate?.count || 0),
      )
    case 'title_asc':
      return pieces.sort((a, b) => (a.title || '').localeCompare(b.title || ''))
    case 'title_desc':
      return pieces.sort((a, b) => (b.title || '').localeCompare(a.title || ''))
    case 'newest':
    default:
      return pieces.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
  }
})

// Filter option builders
const glazeOptions = computed(() => {
  const glazes = new Map()
  allVisiblePieces.value.forEach((piece) =>
    piece.piece_glazes?.forEach((pg) => {
      if (pg.glaze && !glazes.has(pg.glaze.id)) {
        glazes.set(pg.glaze.id, {
          id: pg.glaze.id,
          name: pg.glaze.name,
          brand: pg.glaze.brand || 'Unknown',
          color: pg.glaze.color || 'Unknown',
        })
      }
    }),
  )
  return Array.from(glazes.values()).sort((a, b) => a.name.localeCompare(b.name))
})

const clayOptions = computed(() => {
  const clays = new Map()
  allVisiblePieces.value.forEach((piece) =>
    piece.piece_clays?.forEach((pc) => {
      if (pc.clay_body && !clays.has(pc.clay_body.id)) {
        clays.set(pc.clay_body.id, {
          id: pc.clay_body.id,
          name: pc.clay_body.name,
          brand: pc.clay_body.brand || 'Unknown',
        })
      }
    }),
  )
  return Array.from(clays.values()).sort((a, b) => a.name.localeCompare(b.name))
})

const firingOptions = computed(() => {
  const cones = new Set()
  allVisiblePieces.value.forEach((piece) =>
    piece.piece_firings?.forEach((pf) => pf.cone && cones.add(pf.cone)),
  )
  return Array.from(cones)
    .sort((a, b) => a - b)
    .map((cone) => ({ cone, label: `Cone ${cone}` }))
})

// Helpers
const hasActiveFilters = computed(
  () =>
    selectedGlazes.value.length > 0 ||
    selectedClays.value.length > 0 ||
    selectedFirings.value.length > 0,
)

function toggleLikedView() {
  viewMode.value = viewMode.value === 'liked' ? 'all' : 'liked'
}

function toggleSearchOperator() {
  searchOperator.value = searchOperator.value === 'AND' ? 'OR' : 'AND'
}

function clearAllFilters() {
  selectedGlazes.value = []
  selectedClays.value = []
  selectedFirings.value = []
}
</script>

<style scoped>
.q-chip {
  cursor: pointer;
}
</style>
