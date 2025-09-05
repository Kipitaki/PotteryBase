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
    <photo-gallery-editor v-model="form.photos" class="q-mb-md" readonly />

    <div class="row q-col-gutter-md">
      <!-- LEFT: Stages -->
      <div class="col-12 col-md-4">
        <stage-checklist
          :stages="STAGES"
          v-model:stageDates="form.stageDates"
          v-model:stageLocation="form.stageLocation"
          readonly
        />
      </div>

      <!-- RIGHT: Clay / Glaze / Firing / Notes -->
      <div class="col-12 col-md-8">
        <!-- Clays -->
        <section-card>
          <template #title>Clays</template>
          <div class="row q-gutter-xs wrap">
            <q-chip
              v-for="c in form.clays"
              :key="c.id"
              color="brown-3"
              text-color="black"
              dense
              size="sm"
            >
              {{ c.clayName }}
            </q-chip>
          </div>
        </section-card>

        <!-- Glazes -->
        <section-card>
          <template #title>Glazes</template>
          <div class="row q-gutter-xs wrap">
            <q-chip
              v-for="g in form.glazes"
              :key="g.id"
              color="teal-3"
              text-color="black"
              dense
              size="sm"
            >
              {{ g.glazeId ? g.glazeId : 'Unknown Glaze' }}
            </q-chip>
          </div>
        </section-card>

        <!-- Firings -->
        <section-card>
          <template #title>Firings</template>
          <div class="row q-gutter-xs wrap">
            <q-chip
              v-for="f in form.firings"
              :key="f.id"
              color="red-3"
              text-color="black"
              dense
              size="sm"
            >
              Cone {{ f.cone < 10 ? '0' + f.cone : f.cone }}
            </q-chip>
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
import PhotoGalleryEditor from 'src/components/PhotoGalleryEditor.vue'
import StageChecklist from 'src/components/StageChecklist.vue'
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
  form.title = piece.title
  form.share = piece.visibility || 'private'
  form.notes = piece.notes || ''

  form.clays =
    piece.piece_clays?.map((c) => ({
      id: c.id,
      clayName: c.clay_body?.name,
    })) || []

  form.glazes =
    piece.piece_glazes?.map((g) => ({
      id: g.id,
      glazeId: g.glaze?.name,
    })) || []

  form.firings = piece.piece_firings || []
  form.photos = piece.piece_images || []

  form.stageDates =
    piece.piece_stage_histories?.reduce((acc, sh) => {
      acc[sh.stage] = sh.date
      return acc
    }, emptyStageDates()) || emptyStageDates()
}

/* ---------- Load existing piece ---------- */
onMounted(async () => {
  const id = Array.isArray(route.query.id) ? route.query.id[0] : route.query.id
  if (id) {
    const piece = await piecesStore.getPieceById(id)
    if (piece) hydrateForm(piece)
  }
})

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
