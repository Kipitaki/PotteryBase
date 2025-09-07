<template>
  <q-page padding class="bg-grey-1">
    <!-- Header -->
    <piece-header-bar
      v-model:title="form.title"
      v-model:share="form.share"
      :latest="latestStage"
      :stage-label-map="stageLabelMap"
      readonly
    />

    <!-- Photos -->
    <section-card>
      <template #title>Photos</template>
      <div class="row q-gutter-sm justify-center">
        <q-img
          v-for="(p, idx) in form.photos"
          :key="p.id || idx"
          :src="p.url"
          ratio="1"
          style="width: 200px; height: 200px; border-radius: 8px"
          class="shadow-1"
        />
      </div>
    </section-card>

    <div class="row q-col-gutter-md">
      <!-- LEFT: Stages -->
      <div class="col-12 col-md-4">
        <section-card>
          <template #title>Stages</template>
          <div class="column q-gutter-sm">
            <div v-for="s in filledStages" :key="s.key" class="row items-center q-gutter-sm">
              <q-chip color="blue-3" text-color="black" size="md" square>
                {{ stageLabelMap[s.key] }}
              </q-chip>
              <div class="text-caption text-grey-8">{{ s.date }}</div>
            </div>
          </div>
        </section-card>
      </div>

      <!-- RIGHT: Clay / Glaze / Firing / Notes -->
      <div class="col-12 col-md-8">
        <!-- Glazes -->
        <section-card>
          <template #title>Glazes</template>
          <div class="column q-gutter-sm">
            <div v-for="g in form.glazes" :key="g.id" class="row items-center q-gutter-sm">
              <q-chip color="teal-3" text-color="black" size="md" square>
                {{ g.glazeName || 'Unknown Glaze' }}
              </q-chip>
              <div class="text-body2">Layer: {{ g.layer || '-' }}</div>
              <div class="text-body2">Method: {{ g.method || '-' }}</div>
              <div class="text-body2">Notes: {{ g.notes || '-' }}</div>
            </div>
          </div>
        </section-card>

        <!-- Clays -->
        <section-card>
          <template #title>Clays</template>
          <div class="column q-gutter-sm">
            <div v-for="c in form.clays" :key="c.id" class="row items-center q-gutter-sm">
              <q-chip color="brown-3" text-color="black" size="md" square>
                {{ c.clayName }}
              </q-chip>
              <div class="text-body2">Notes: {{ c.notes || '-' }}</div>
            </div>
          </div>
        </section-card>

        <!-- Firings -->
        <section-card>
          <template #title>Firings</template>
          <div class="column q-gutter-sm">
            <div v-for="f in form.firings" :key="f.id" class="row items-center q-gutter-sm">
              <q-chip color="red-3" text-color="black" size="md" square> Cone {{ f.cone }} </q-chip>
              <div class="text-body2">Method: {{ f.method || '-' }}</div>
              <div class="text-body2">Notes: {{ f.notes || '-' }}</div>
            </div>
          </div>
        </section-card>

        <!-- Notes -->
        <section-card>
          <template #title>Notes</template>
          <q-input v-model="form.notes" type="textarea" autogrow dense readonly />
        </section-card>
      </div>
    </div>

    <!-- Actions -->
    <div class="row items-center justify-end q-gutter-sm q-mt-md">
      <q-btn flat dense icon="inventory_2" label="Back to Shelf" :to="{ name: 'shelf' }" />
    </div>
  </q-page>
</template>

<script setup>
import { reactive, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'

import PieceHeaderBar from 'src/components/PieceHeaderBar.vue'
import SectionCard from 'src/components/SectionCard.vue'
import { usePiecesStore } from 'src/stores/pieces'

const piecesStore = usePiecesStore()
const route = useRoute()

/* ---------- Stages ---------- */
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
const stageLabelMap = Object.fromEntries(STAGES.map((s) => [s.value, s.label]))
const stageOrder = STAGES.map((s) => s.value)

function emptyStageDates() {
  const obj = {}
  stageOrder.forEach((k) => (obj[k] = ''))
  return obj
}

/* ---------- Form (readonly data) ---------- */
const form = reactive({
  title: '',
  share: 'private',
  photos: [],
  stageLocation: '',
  stageDates: emptyStageDates(),
  clays: [],
  glazes: [],
  firings: [],
  notes: '',
})

/* ---------- Hydrate form ---------- */
function hydrateForm(piece) {
  form.title = piece.title || ''
  form.share = piece.visibility || 'private'
  form.notes = piece.notes || ''

  // Clays
  form.clays =
    piece.piece_clays?.map((c) => ({
      id: c.id,
      clayName: c.clay_body?.name || 'Unknown Clay',
      notes: c.notes || '',
    })) || []

  // Glazes
  form.glazes =
    piece.piece_glazes?.map((g) => ({
      id: g.id,
      glazeName: g.glaze?.name || 'Unknown Glaze',
      layer: g.layer || '',
      method: g.method || '',
      notes: g.notes || '',
    })) || []

  // Firings
  form.firings =
    piece.piece_firings?.map((f) => ({
      id: f.id,
      cone: f.cone || '',
      method: f.method || '',
      notes: f.notes || '',
    })) || []

  // Photos (normalize shape and prefer is_main if available)
  form.photos =
    piece.piece_images?.map((img) => ({
      id: img.id,
      url: img.url || img.image_url || '', // adjust to match your API
      is_main: img.is_main || false,
    })) || []

  // Stages → normalize to yyyy-MM-dd
  const stageDates = emptyStageDates()
  if (piece.piece_stage_histories?.length) {
    piece.piece_stage_histories.forEach((sh) => {
      if (sh.stage) {
        stageDates[sh.stage] = sh.date ? new Date(sh.date).toISOString().split('T')[0] : ''
      }
    })
  }
  form.stageDates = stageDates
}

/* ---------- Load existing piece ---------- */
onMounted(async () => {
  const id = Array.isArray(route.query.id) ? route.query.id[0] : route.query.id
  if (id) {
    const piece = await piecesStore.getPieceById(id)
    if (piece) hydrateForm(piece)
  }
})
const filledStages = computed(() =>
  stageOrder
    .filter((k) => form.stageDates[k])
    .map((k) => ({
      key: k,
      date: form.stageDates[k],
    })),
)

/* ---------- Latest stage ---------- */
const latestStage = computed(() => {
  for (let i = stageOrder.length - 1; i >= 0; i--) {
    const k = stageOrder[i]
    const date = form.stageDates[k]
    if (date) return { key: k, date }
  }
  return null
})
</script>
