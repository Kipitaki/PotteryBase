<template>
  <q-card class="piece-card" flat bordered v-bind="$attrs" :data-piece-id="piece.id">
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
        :size="$q.screen.lt.md ? 'sm' : 'md'"
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
        :size="$q.screen.lt.md ? 'xs' : 'sm'"
      >
        <q-icon :name="visibilityIcon" :size="$q.screen.lt.md ? '10px' : '12px'" class="q-mr-xs" />
        {{ visibilityLabel }}
      </q-chip>
      <q-chip
        v-else
        class="visibility-chip"
        color="grey-7"
        text-color="white"
        dense
        square
        :size="$q.screen.lt.md ? 'xs' : 'sm'"
      >
        <q-icon name="person" :size="$q.screen.lt.md ? '10px' : '12px'" class="q-mr-xs" />
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
      <!-- Delete button (only if owner) -->
      <q-btn
        v-if="isOwner"
        class="delete-btn"
        icon="close"
        dense
        round
        flat
        size="xs"
        color="negative"
        @click="confirmDelete"
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
      <div class="row items-center no-wrap">
        <!-- Fixed-width like slot prevents reflow -->
        <div class="like-slot">
          <q-icon
            :name="isLiked ? 'whatshot' : 'whatshot_outline'"
            :color="isLiked ? 'red' : 'grey-6'"
            size="20px"
            class="cursor-pointer like-icon"
            @click.stop="handleToggleLike"
          >
            <q-tooltip
              v-if="likeTooltipText"
              class="bg-grey-8"
              :offset="[10, 10]"
              anchor="top middle"
              self="bottom middle"
            >
              {{ likeTooltipText }}
            </q-tooltip>
          </q-icon>
        </div>

        <div class="col">
          <div class="text-subtitle1 ellipsis">
            {{ piece?.title || 'Untitled' }}
          </div>
          <div v-if="subtitle" class="text-caption text-grey-6 ellipsis">
            {{ subtitle }}
          </div>
        </div>
      </div>
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
          :size="$q.screen.lt.md ? 'xs' : 'sm'"
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
          :size="$q.screen.lt.md ? 'xs' : 'sm'"
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
          :size="$q.screen.lt.md ? 'xs' : 'sm'"
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

  <!-- Delete Confirmation Dialog -->
  <q-dialog v-model="deleteDialog.open">
    <q-card>
      <q-card-section>
        <div class="text-h6">Delete Piece</div>
        <div class="text-body2 q-mt-sm">
          Are you sure you want to delete "{{ piece?.title || 'Untitled' }}"? This action cannot be
          undone.
        </div>
      </q-card-section>
      <q-card-actions align="right">
        <q-btn flat label="Cancel" @click="deleteDialog.open = false" />
        <q-btn color="negative" label="Delete" @click="deletePiece" />
      </q-card-actions>
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
/* ============================================================
   LIKES HANDLING
   ============================================================ */
const isLiked = computed(() => piecesStore.isLikedByUser(props.piece.id))
const likeTooltipText = computed(() => piecesStore.getLikeTooltipText(props.piece.id))

async function handleToggleLike() {
  try {
    await piecesStore.toggleLike(props.piece.id)
  } catch (error) {
    console.error('Error toggling like:', error)
    // You could add a notification here if you have a notification system
  }
}
// Delete dialog
const deleteDialog = ref({
  open: false,
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
function onDragOver(e) {
  // Only handle file drags, not card drags
  if (e.dataTransfer.types.includes('Files')) {
    isDragOver.value = true
  }
}
function onDragLeave() {
  isDragOver.value = false
}
async function handleDrop(e) {
  isDragOver.value = false
  // Only handle file drops, not card drops
  if (e.dataTransfer.types.includes('Files')) {
    const files = e.dataTransfer.files
    if (!files.length) return
    await saveFiles(Array.from(files))
  }
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
const STAGE_ORDER = ['lump', 'formed', 'trimmed', 'bisque', 'glazed', 'fired', 'archived', 'failed']
const LABELS = {
  lump: 'Lump',
  formed: 'Formed',
  trimmed: 'Trimmed',
  bisque: 'Bisque',
  glazed: 'Glazed',
  fired: 'Fired',
  archived: 'Archived',
  failed: 'Failed',
}
const COLORS = {
  lump: 'blue-grey-3',
  formed: 'blue-grey-4',
  trimmed: 'indigo-3',
  bisque: 'orange-3',
  glazed: 'teal-3',
  fired: 'red-3',
  archived: 'purple-3',
  failed: 'brown-3',
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

/* ============================================================
   DELETE HANDLING
   ============================================================ */
function confirmDelete() {
  deleteDialog.value.open = true
}

async function deletePiece() {
  try {
    await piecesStore.deletePiece(props.piece.id)
    deleteDialog.value.open = false
    // The piece will be removed from the list automatically via reactivity
  } catch (error) {
    console.error('Error deleting piece:', error)
    // You could add a notification here if you have a notification system
  }
}
</script>

<style scoped>
.piece-card {
  width: 100%; /* takes full column */
  margin: 0;
}

@media (max-width: 600px) {
  .piece-card {
    max-width: 160px;
    font-size: 12px;
  }
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
.delete-btn {
  position: absolute;
  right: 6px;
  bottom: 6px;
  background: transparent;
  opacity: 0.8;
  min-width: 24px;
  min-height: 24px;
}
.tight {
  padding: 4px 8px;
}

@media (max-width: 600px) {
  .tight {
    padding: 3px 6px;
  }
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

@media (max-width: 600px) {
  .card-thumb {
    min-height: 120px;
  }
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

@media (max-width: 600px) {
  .thumb-img {
    width: 32px;
    height: 32px;
  }
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
.q-btn[icon='whatshot'] {
  transition: transform 0.2s;
}
.q-btn[icon='whatshot']:active {
  transform: scale(1.2);
}
.like-slot {
  width: 28px; /* keep icon width stable */
  display: flex;
  align-items: center;
  justify-content: center;
}
.like-icon {
  display: inline-block;
}
</style>
