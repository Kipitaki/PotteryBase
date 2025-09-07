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

    <!-- Notes -->
    <div class="row q-col-gutter-md items-start q-mb-md">
      <div class="col-12 col-md-6">
        <q-input
          :model-value="form.notes"
          label="Notes"
          dense
          hide-bottom-space
          readonly
          placeholder="No notes added"
        />
      </div>
    </div>

    <!-- Photos (Compact Horizontal Layout) -->
    <section-card>
      <template #title>Photos</template>
      <div class="row q-gutter-sm justify-start">
        <!-- Main Photo -->
        <q-img
          v-if="mainPhoto"
          :key="mainPhoto.id"
          :src="mainPhoto.url"
          ratio="1"
          :style="{
            width: '300px',
            height: '300px',
            borderRadius: '8px',
          }"
          class="shadow-1 cursor-pointer"
          @click="openImageDialog(mainPhoto.url)"
        />

        <!-- Additional Photos in Horizontal Row -->
        <div v-if="otherPhotos.length > 0" class="row q-gutter-sm">
          <q-img
            v-for="p in otherPhotos"
            :key="p.id"
            :src="p.url"
            ratio="1"
            :style="{
              width: '120px',
              height: '120px',
              borderRadius: '8px',
            }"
            class="shadow-1 cursor-pointer"
            @click="openImageDialog(p.url)"
          />
        </div>
      </div>
    </section-card>

    <div class="row q-col-gutter-md">
      <!-- LEFT: Stages -->
      <div class="col-12 col-md-4">
        <section-card>
          <template #title>Stages</template>
          <div class="column q-gutter-sm">
            <div v-for="s in filledStages" :key="s.key" class="stage-item">
              <div class="row items-center q-gutter-md">
                <q-chip color="blue-3" text-color="black" size="md" square>
                  {{ stageLabelMap[s.key] }}
                </q-chip>
                <div class="column">
                  <div class="text-body2">{{ formatDate(s.date) }}</div>
                  <div
                    v-if="s.dimensions && s.dimensions.location"
                    class="text-caption text-grey-6"
                  >
                    📍 {{ s.dimensions.location }}
                  </div>
                </div>
                <div
                  v-if="
                    s.dimensions &&
                    (s.dimensions.length || s.dimensions.width || s.dimensions.height)
                  "
                  class="text-body2"
                >
                  📏 {{ s.dimensions.length || '-' }}×{{ s.dimensions.width || '-' }}×{{
                    s.dimensions.height || '-'
                  }}
                  {{ unitDisplay.includes('Metric') ? 'cm' : 'in' }}
                </div>
                <div v-if="s.dimensions && s.dimensions.weight" class="text-body2">
                  ⚖️ {{ s.dimensions.weight }} {{ unitDisplay.includes('Metric') ? 'g' : 'lb' }}
                </div>
              </div>
            </div>
          </div>
        </section-card>
      </div>

      <!-- RIGHT: Clay, Glaze, Firing -->
      <div class="col-12 col-md-8">
        <!-- Glazes -->
        <section-card>
          <template #title>Glazes</template>
          <div class="column q-gutter-md">
            <div
              v-for="g in form.glazes"
              :key="g.id"
              class="glaze-item q-pa-sm bg-grey-1 rounded-borders"
            >
              <div class="row items-center q-gutter-md q-mb-sm">
                <q-chip color="teal-3" text-color="black" size="md" square>
                  {{ g.glazeName || 'Unknown Glaze' }}
                </q-chip>
                <div v-if="g.layer" class="text-body2">Layer: {{ g.layer }}</div>
                <div v-if="g.method" class="text-body2">Method: {{ g.method }}</div>
                <div v-if="g.notes" class="text-body2">Notes: {{ g.notes }}</div>
              </div>
              <div class="row q-gutter-md text-caption text-grey-7">
                <div v-if="g.brand">Brand: {{ g.brand }}</div>
                <div v-if="g.code">Code: {{ g.code }}</div>
                <div v-if="g.color">Color: {{ g.color }}</div>
                <div v-if="g.cone">Cone: {{ g.cone }}</div>
                <div v-if="g.finish">Finish: {{ g.finish }}</div>
                <div v-if="g.series">Series: {{ g.series }}</div>
                <div v-if="g.displayName">Display: {{ g.displayName }}</div>
                <div v-if="g.glazeNotes">Glaze Notes: {{ g.glazeNotes }}</div>
              </div>
            </div>
          </div>
        </section-card>

        <!-- Clays -->
        <section-card>
          <template #title>Clays</template>
          <div class="column q-gutter-md">
            <div
              v-for="c in form.clays"
              :key="c.id"
              class="clay-item q-pa-sm bg-grey-1 rounded-borders"
            >
              <div class="row items-center q-gutter-md">
                <q-chip color="brown-3" text-color="black" size="md" square>
                  {{ c.clayName }}
                </q-chip>
                <div v-if="c.notes" class="text-body2">Notes: {{ c.notes }}</div>
              </div>
            </div>
          </div>
        </section-card>

        <!-- Firings -->
        <section-card>
          <template #title>Firings</template>
          <div class="column q-gutter-md">
            <div
              v-for="f in form.firings"
              :key="f.id"
              class="firing-item q-pa-sm bg-grey-1 rounded-borders"
            >
              <div class="row items-center q-gutter-md">
                <q-chip color="red-3" text-color="black" size="md" square>
                  Cone {{ f.cone }}
                </q-chip>
                <div v-if="f.temperature" class="text-body2">Temp: {{ f.temperature }}°F</div>
                <div v-if="f.kilnType" class="text-body2">Kiln Type: {{ f.kilnType }}</div>
                <div v-if="f.kilnLocation" class="text-body2">Location: {{ f.kilnLocation }}</div>
                <div v-if="f.loadName" class="text-body2">Load: {{ f.loadName }}</div>
                <div v-if="f.date" class="text-body2">Date: {{ formatDate(f.date) }}</div>
                <div v-if="f.notes" class="text-body2">Notes: {{ f.notes }}</div>
              </div>
            </div>
          </div>
        </section-card>
      </div>
    </div>

    <!-- Actions -->
    <div class="row items-center justify-between q-gutter-sm q-mt-md">
      <div>
        <q-btn
          v-if="isOwner"
          color="primary"
          icon="edit"
          label="Edit Piece"
          :to="{ name: 'add-piece', query: { id: form.piece?.id } }"
        />
      </div>
      <div>
        <q-btn flat dense icon="inventory_2" label="Back to Shelf" :to="{ name: 'shelf' }" />
      </div>
    </div>

    <!-- Image Dialog -->
    <q-dialog v-model="imageDialog.open" maximized>
      <q-card>
        <q-card-section class="row items-center q-pb-none">
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>
        <q-card-section class="flex flex-center">
          <q-img
            :src="imageDialog.url"
            style="max-width: 90vw; max-height: 80vh; object-fit: contain"
            fit="contain"
          />
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { reactive, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'

import PieceHeaderBar from 'src/components/PieceHeaderBar.vue'
import SectionCard from 'src/components/SectionCard.vue'
import { usePiecesStore } from 'src/stores/pieces'
import { useProfileStore } from 'src/stores/profile'
import { nhost } from 'boot/nhost'

const piecesStore = usePiecesStore()
const profileStore = useProfileStore()
const route = useRoute()

// Ownership check
const isOwner = computed(() => {
  const user = nhost.auth.getUser()
  return form.piece?.owner_id && user?.id === form.piece.owner_id
})

// Image dialog
const imageDialog = reactive({
  open: false,
  url: '',
})

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
  piece: null,
  title: '',
  share: 'private',
  photos: [],
  stageLocation: '',
  stageDates: emptyStageDates(),
  stageDimensions: {},
  clays: [],
  glazes: [],
  firings: [],
  notes: '',
})

// Unit display
const unitDisplay = computed(() =>
  profileStore.isMetric.value ? 'Metric (cm/g)' : 'Imperial (in/lb)',
)

// Functions
function openImageDialog(url) {
  imageDialog.url = url
  imageDialog.open = true
}

function formatDate(dateString) {
  if (!dateString) return ''
  const date = new Date(dateString)
  const month = (date.getMonth() + 1).toString().padStart(2, '0')
  const day = date.getDate().toString().padStart(2, '0')
  const year = date.getFullYear().toString().slice(-2)
  return `${month}/${day}/${year}`
}

/* ---------- Hydrate form ---------- */
function hydrateForm(piece) {
  form.piece = piece
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
      layer: g.layer_number || '',
      method: g.application_method || '',
      notes: g.notes || '',
      // Glaze attributes
      brand: g.glaze?.brand || '',
      code: g.glaze?.code || '',
      color: g.glaze?.color || '',
      cone: g.glaze?.cone || '',
      displayName: g.glaze?.display_name || '',
      finish: g.glaze?.finish || '',
      series: g.glaze?.series || '',
      glazeNotes: g.glaze?.notes || '',
    })) || []

  // Firings
  form.firings =
    piece.piece_firings?.map((f) => ({
      id: f.id,
      cone: f.cone || '',
      temperature: f.temperature_f || '',
      kilnType: f.kiln_type || '',
      kilnLocation: f.kiln_location || '',
      loadName: f.load_name || '',
      date: f.date || '',
      notes: f.notes || '',
    })) || []

  // Photos (normalize shape and prefer is_main if available)
  form.photos =
    piece.piece_images?.map((img) => ({
      id: img.id,
      url: img.url || img.image_url || '', // adjust to match your API
      is_main: img.is_main || false,
    })) || []

  // Stages → normalize to yyyy-MM-dd and include dimensions
  const stageDates = emptyStageDates()
  const stageDimensions = {}
  if (piece.piece_stage_histories?.length) {
    piece.piece_stage_histories.forEach((sh) => {
      if (sh.stage) {
        stageDates[sh.stage] = sh.date ? new Date(sh.date).toISOString().split('T')[0] : ''
        stageDimensions[sh.stage] = {
          length: sh.length_cm ? profileStore.toLengthInput(sh.length_cm) : null,
          width: sh.width_cm ? profileStore.toLengthInput(sh.width_cm) : null,
          height: sh.height_cm ? profileStore.toLengthInput(sh.height_cm) : null,
          weight: sh.weight_g ? profileStore.toWeightInput(sh.weight_g) : null,
          location: sh.location,
        }
      }
    })
  }
  form.stageDates = stageDates
  form.stageDimensions = stageDimensions
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
      dimensions: form.stageDimensions[k] || null,
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

/* ---------- Main photo ---------- */
const mainPhoto = computed(() => {
  if (!form.photos || form.photos.length === 0) return null

  // Find photo marked as main
  const main = form.photos.find((p) => p.is_main)
  if (main) return main

  // Fallback to first photo
  return form.photos[0]
})

/* ---------- Other photos (excluding main) ---------- */
const otherPhotos = computed(() => {
  if (!form.photos || form.photos.length <= 1) return []

  const main = mainPhoto.value
  return form.photos.filter((p) => p.id !== main?.id)
})
</script>

<style scoped>
.stage-item {
  border-left: 3px solid #1976d2;
  padding-left: 8px;
  margin-bottom: 8px;
}

.stage-details {
  font-size: 0.75rem;
  line-height: 1.4;
}

.glaze-item,
.clay-item,
.firing-item {
  border: 1px solid #e0e0e0;
  transition: box-shadow 0.2s;
}

.glaze-item:hover,
.clay-item:hover,
.firing-item:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.rounded-borders {
  border-radius: 8px;
}
</style>
