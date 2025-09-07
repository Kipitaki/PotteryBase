<template>
  <q-card class="piece-card" flat bordered v-bind="$attrs">
    <!-- ---------------- Image Area ---------------- -->
    <div
      class="img-wrap"
      @dragover.prevent="onDragOver"
      @dragleave="onDragLeave"
      @drop.prevent="handleDrop"
      :class="{ dragover: isDragOver }"
    >
      <!-- Main photo -->
      <q-img
        :src="mainPhotoUrl"
        ratio="1"
        class="card-thumb cursor-pointer"
        @click="openImageDialog(mainPhotoUrl)"
      />

      <!-- Stage chip -->
      <q-chip
        v-if="stageLabel"
        class="stage-chip"
        :color="stageColor"
        text-color="white"
        dense
        square
      >
        {{ stageLabel }}
      </q-chip>

      <!-- Visibility chip OR Owner chip -->
      <q-chip
        v-if="isOwner"
        class="visibility-chip"
        :color="visibilityColor"
        text-color="white"
        dense
        square
        size="sm"
      >
        <q-icon :name="visibilityIcon" size="12px" class="q-mr-xs" />
        {{ visibilityLabel }}
      </q-chip>
      <q-chip
        v-else
        class="visibility-chip"
        color="grey-7"
        text-color="white"
        dense
        square
        size="sm"
      >
        <q-icon name="person" size="12px" class="q-mr-xs" />
        {{ piece.profile?.display_name || 'Unknown Owner' }}
      </q-chip>

      <!-- Edit button (only if owner) -->
      <q-btn
        v-if="isOwner"
        class="edit-btn"
        icon="edit"
        dense
        round
        flat
        size="sm"
        @click="goEdit"
      />
      <!-- View button -->
      <q-btn
        class="view-btn"
        icon="visibility"
        dense
        round
        flat
        size="sm"
        :class="{ 'view-btn-owner': isOwner, 'view-btn-not-owner': !isOwner }"
        @click="goView"
      />
      <!-- Upload button (only if owner) -->
      <q-btn
        v-if="isOwner"
        class="upload-btn"
        icon="add_photo_alternate"
        dense
        round
        flat
        size="sm"
        @click="triggerFileInput"
      />
      <input
        ref="fileInput"
        type="file"
        accept="image/*"
        class="hidden"
        @change="handleFileInput"
      />
    </div>

    <!-- Thumbnails -->
    <div v-if="photos.length > 1" class="thumb-strip row q-gutter-xs q-pa-xs">
      <q-img
        v-for="photo in photos"
        :key="photo.id"
        :src="photo.url"
        ratio="1"
        class="thumb-img cursor-pointer"
        @click="selectThumbnailAndOpenDialog(photo.id, photo.url)"
      />
    </div>

    <!-- ---------------- Title ---------------- -->
    <q-card-section class="tight">
      <div class="text-subtitle1 ellipsis">{{ piece?.title || 'Untitled' }}</div>
      <div v-if="subtitle" class="text-caption text-grey-6 ellipsis">{{ subtitle }}</div>
    </q-card-section>

    <!-- ---------------- Clays ---------------- -->
    <q-card-section v-if="piece?.piece_clays?.length" class="tight divider">
      <div class="row q-gutter-xs items-center wrap">
        <q-chip
          v-for="c in piece.piece_clays"
          :key="c.id"
          color="brown-3"
          text-color="black"
          dense
          size="sm"
        >
          {{ c.clay_body?.name || 'Unknown' }}
        </q-chip>
      </div>
    </q-card-section>

    <!-- ---------------- Glazes ---------------- -->
    <q-card-section v-if="piece?.piece_glazes?.length" class="tight divider">
      <div class="row q-gutter-xs items-center wrap">
        <q-chip
          v-for="g in piece.piece_glazes"
          :key="g.id"
          color="teal-3"
          text-color="black"
          dense
          size="sm"
        >
          {{ g.glaze?.name }}
        </q-chip>
      </div>
    </q-card-section>

    <!-- ---------------- Firings ---------------- -->
    <q-card-section v-if="piece?.piece_firings?.length" class="tight divider">
      <div class="row q-gutter-xs items-center wrap">
        <q-chip
          v-for="f in piece.piece_firings"
          :key="f.id"
          color="red-3"
          text-color="black"
          dense
          size="sm"
        >
          Cone {{ f.cone }}
        </q-chip>
      </div>
    </q-card-section>
  </q-card>

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
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { nhost } from 'boot/nhost'
import { usePiecesStore } from 'src/stores/pieces'

const router = useRouter()
const piecesStore = usePiecesStore()

const props = defineProps({
  piece: { type: Object, required: true },
  subtitle: { type: String, default: '' },
})

// Manually handle draggable attributes
defineOptions({
  inheritAttrs: false,
})

/* ---------- Auth + Ownership ---------- */
const isOwner = computed(() => {
  const user = nhost.auth.getUser()
  return props.piece?.owner_id && user?.id === props.piece.owner_id
})

/* ============================================================
   PHOTO HANDLING
   ============================================================ */
const photos = ref([])
const currentPhotoId = ref(null)
const fileInput = ref(null)
const isDragOver = ref(false)

// Image dialog
const imageDialog = ref({
  open: false,
  url: '',
})

onMounted(() => {
  photos.value = props.piece?.piece_images || []
})

const mainPhotoUrl = computed(() => {
  const current = photos.value.find((p) => p.id === currentPhotoId.value)
  if (current) return current.url
  const main = photos.value.find((p) => p.is_main)
  return main?.url || 'https://picsum.photos/800/600?grayscale'
})

function selectThumbnail(id) {
  currentPhotoId.value = id
}

function selectThumbnailAndOpenDialog(id, url) {
  selectThumbnail(id)
  openImageDialog(url)
}

function openImageDialog(url) {
  imageDialog.value.url = url
  imageDialog.value.open = true
}
function triggerFileInput() {
  fileInput.value?.click()
}
async function handleFileInput(e) {
  const files = e.target.files
  if (!files.length) return
  await saveFiles(Array.from(files))
  e.target.value = ''
}
function onDragOver() {
  isDragOver.value = true
}
function onDragLeave() {
  isDragOver.value = false
}
async function handleDrop(e) {
  isDragOver.value = false
  const files = e.dataTransfer.files
  if (!files.length) return
  await saveFiles(Array.from(files))
}
async function saveFiles(files) {
  for (const file of files) {
    if (!file.type.startsWith('image/')) continue
    try {
      const { fileMetadata, error } = await nhost.storage.upload({
        file,
        bucketId: 'default',
        options: { public: true },
      })
      if (error) throw error
      const url = nhost.storage.getPublicUrl({ fileId: fileMetadata.id })
      const newImg = await piecesStore.addImage({
        piece_id: props.piece.id,
        file_id: fileMetadata.id,
        url,
        is_main: photos.value.length === 0,
      })
      photos.value = [...photos.value, newImg]
    } catch (err) {
      console.error('Image upload failed', err)
    }
  }
}
function goView() {
  router.push({ name: 'viewpiece', query: { id: props.piece.id } })
}

/* ============================================================
   STAGE HANDLING
   ============================================================ */
const STAGE_ORDER = [
  'lump',
  'formed',
  'trimmed',
  'bisque',
  'glazed',
  'fired',
  'sold_posted',
  'sold_kept',
]
const LABELS = {
  lump: 'Lump',
  formed: 'Formed',
  trimmed: 'Trimmed',
  bisque: 'Bisque',
  glazed: 'Glazed',
  fired: 'Fired',
  sold_posted: 'Sold/Posted',
  sold_kept: 'Sold/Kept',
}
const COLORS = {
  lump: 'blue-grey-3',
  formed: 'blue-grey-4',
  trimmed: 'indigo-3',
  bisque: 'orange-3',
  glazed: 'teal-3',
  fired: 'red-3',
  sold_posted: 'purple-3',
  sold_kept: 'brown-3',
}
const stageHistories = computed(() => props.piece?.piece_stage_histories || [])
const stageKey = computed(() => {
  const completed = stageHistories.value.map((h) => h.stage)
  for (let i = STAGE_ORDER.length - 1; i >= 0; i--) {
    if (completed.includes(STAGE_ORDER[i])) return STAGE_ORDER[i]
  }
  return null
})
const stageLabel = computed(() => (stageKey.value ? LABELS[stageKey.value] : ''))
const stageColor = computed(() => (stageKey.value ? COLORS[stageKey.value] : 'blue-grey-4'))

/* ============================================================
   VISIBILITY HANDLING
   ============================================================ */
const VISIBILITY_LABELS = {
  public: 'Public',
  community: 'Community',
  community_group: 'Group',
  private: 'Private',
}
const VISIBILITY_COLORS = {
  public: 'green',
  community: 'blue',
  community_group: 'purple',
  private: 'grey-6',
}
const VISIBILITY_ICONS = {
  public: 'public',
  community: 'group',
  community_group: 'groups',
  private: 'lock',
}
const visibilityLabel = computed(() => {
  const visibility = props.piece?.visibility || 'private'
  return VISIBILITY_LABELS[visibility] || 'Private'
})
const visibilityColor = computed(() => {
  const visibility = props.piece?.visibility || 'private'
  return VISIBILITY_COLORS[visibility] || 'grey-6'
})
const visibilityIcon = computed(() => {
  const visibility = props.piece?.visibility || 'private'
  return VISIBILITY_ICONS[visibility] || 'lock'
})

/* ============================================================
   ROUTER
   ============================================================ */
function goEdit() {
  router.push({ name: 'addpiece', query: { id: props.piece.id } })
}
</script>

<style scoped>
.piece-card {
  width: 240px;
  font-size: 14px;
  display: flex;
  flex-direction: column;
}
.img-wrap {
  position: relative;
  border: 2px dashed transparent;
  transition: border-color 0.2s;
}
.img-wrap.dragover {
  border-color: #42a5f5;
}
.stage-chip {
  position: absolute;
  left: 6px;
  top: 6px;
}
.visibility-chip {
  position: absolute;
  left: 6px;
  bottom: 6px;
}
.edit-btn {
  position: absolute;
  right: 6px;
  top: 6px;
  background: white;
}
.upload-btn {
  position: absolute;
  right: 40px;
  top: 6px;
  background: white;
}
.tight {
  padding: 4px 8px;
}
.divider {
  border-top: 1px solid #e0e0e0;
}
.q-chip {
  margin: 2px !important;
}
.card-thumb {
  width: 100%;
  min-height: 150px;
  border-bottom: 1px solid #eee;
}
.thumb-strip {
  overflow-x: auto;
}
.thumb-img {
  width: 40px;
  height: 40px;
  border: 2px solid transparent;
  border-radius: 4px;
}
.thumb-img:hover {
  border-color: #42a5f5;
}
.view-btn-owner {
  right: 74px; /* sits left of edit/upload when owner */
  top: 6px;
  background: white;
  position: absolute;
}

.view-btn-not-owner {
  right: 6px; /* bump to the far right when not owner */
  top: 6px;
  background: white;
  position: absolute;
}
</style>
