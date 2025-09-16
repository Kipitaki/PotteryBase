<template>
  <section-card>
    <!-- Title row with drop area -->
    <template #title>
      <div class="row items-center justify-between full-width">
        <div class="row items-center q-gutter-sm">
          <span>Photos</span>
          <q-btn
            flat
            dense
            icon="add_photo_alternate"
            label="Add Photo"
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
        <!-- Drag area inline -->
        <div
          class="drop-inline text-caption text-grey-7"
          @dragover.prevent
          @drop.prevent="handleDrop"
        >
          Drag & drop here
        </div>
      </div>
    </template>

    <!-- Photos grid -->
    <div class="row q-col-gutter-md q-mt-md">
      <div
        v-for="photo in photos"
        :key="photo.tempId || photo.id"
        class="col-auto"
        style="width: 200px"
      >
        <div class="relative-position">
          <!-- Thumbnail -->
          <q-img
            :src="photo.previewUrl || photo.url"
            style="width: 100%; height: 160px; object-fit: cover"
            class="rounded-borders"
          >
            <!-- Uploading overlay -->
            <template v-if="photo.uploading">
              <div class="absolute-full flex flex-center bg-black-50">
                <q-spinner color="white" size="24px" />
              </div>
            </template>
            <!-- Error overlay -->
            <template v-if="photo.error">
              <div class="absolute-full flex flex-center bg-red-50">
                <q-icon name="error" color="negative" size="24px" />
              </div>
            </template>
          </q-img>

          <!-- Main badge -->
          <q-badge
            v-if="photo.is_main"
            color="primary"
            text-color="white"
            class="absolute-top-left q-ma-xs"
          >
            Main
          </q-badge>

          <!-- Set main -->
          <q-btn
            v-else
            size="xs"
            flat
            dense
            color="primary"
            class="absolute-top-left q-ma-xs bg-white"
            label="Set Main"
            @click="setMain(photo.tempId || photo.id)"
          />

          <!-- Delete (X) -->
          <q-btn
            flat
            dense
            size="xs"
            icon="close"
            color="negative"
            class="absolute-bottom-right q-ma-xs"
            @click.stop="removePhoto(photo.tempId || photo.id)"
          />
        </div>

        <!-- Stage + Notes -->
        <q-select
          v-model="photo.stage"
          :options="stageOptions"
          emit-value
          map-options
          label="Stage"
          dense
          clearable
          class="q-mt-sm"
          @update:model-value="(val) => updatePhotoField(photo, 'stage', val)"
        />
        <q-input
          v-model="photo.notes"
          dense
          placeholder="Notes"
          type="textarea"
          autogrow
          class="q-mt-sm"
          @update:model-value="(val) => updatePhotoField(photo, 'notes', val)"
        />
      </div>
    </div>
  </section-card>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import SectionCard from './SectionCard.vue'
import { usePiecesStore } from 'src/stores/pieces'
import { nhost } from 'src/boot/nhost'
import { Notify } from 'quasar'

const piecesStore = usePiecesStore()

const props = defineProps({
  modelValue: { type: Array, default: () => [] }, // local unsaved photos
  pieceId: { type: Number, default: null }, // piece ID for auto-save
  isHydrating: { type: Boolean, default: false }, // prevent auto-save during initial data loading
})
const emit = defineEmits(['update:modelValue'])

// Local reactive copy of photos
const photos = ref([...props.modelValue])

watch(
  () => props.modelValue,
  (val) => (photos.value = [...val]),
)

// Auto-save mode when pieceId is provided
const isAutoSaveMode = computed(() => props.pieceId !== null)

function showAutoSaveToast(message = 'Photo updated') {
  if (isAutoSaveMode.value) {
    Notify.create({
      message,
      type: 'positive',
      timeout: 1500,
      position: 'top',
      progress: true,
    })
  }
}

// Stage options
const stageOptions = [
  { label: 'Lump', value: 'lump' },
  { label: 'Formed', value: 'formed' },
  { label: 'Trimmed', value: 'trimmed' },
  { label: 'Bisque', value: 'bisque' },
  { label: 'Glazed', value: 'glazed' },
  { label: 'Fired', value: 'fired' },
  { label: 'Archived', value: 'archived' },
  { label: 'Failed', value: 'failed' },
]

/* ---------- File input & Drop ---------- */
const fileInput = ref(null)

function triggerFileInput() {
  fileInput.value?.click()
}

function handleFileInput(e) {
  const files = e.target.files
  if (!files.length) return
  addFiles(files)
  e.target.value = '' // reset
}

function handleDrop(e) {
  const files = e.dataTransfer.files
  if (!files.length) return
  addFiles(files)
}

/* ---------- Image resize helper ---------- */
async function resizeImage(file, maxSize = 1600) {
  return new Promise((resolve, reject) => {
    const img = new Image()
    const reader = new FileReader()

    reader.onload = (e) => (img.src = e.target.result)
    reader.onerror = reject

    img.onload = () => {
      const canvas = document.createElement('canvas')
      let { width, height } = img

      if (width > height) {
        if (width > maxSize) {
          height *= maxSize / width
          width = maxSize
        }
      } else {
        if (height > maxSize) {
          width *= maxSize / height
          height = maxSize
        }
      }

      canvas.width = width
      canvas.height = height
      const ctx = canvas.getContext('2d')
      ctx.drawImage(img, 0, 0, width, height)

      canvas.toBlob(
        (blob) => {
          if (!blob) return reject(new Error('Resize failed'))
          resolve(blob)
        },
        'image/jpeg',
        0.8,
      )
    }

    reader.readAsDataURL(file)
  })
}

/* ---------- Add photos with auto-save ---------- */
async function addFiles(files) {
  const newPhotos = []
  for (const file of files) {
    if (!file.type.startsWith('image/')) continue
    const blob = await resizeImage(file, 1600)
    const previewUrl = URL.createObjectURL(blob)

    const tempPhoto = {
      tempId: `ph_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 7)}`,
      file: blob,
      previewUrl,
      stage: null,
      notes: '',
      is_main: photos.value.length === 0,
      uploading: true, // Add uploading state
    }

    newPhotos.push(tempPhoto)

    // Add to UI immediately for better UX
    photos.value = [...photos.value, tempPhoto]
    emit('update:modelValue', photos.value)

    // Auto-save to database if pieceId is provided
    if (isAutoSaveMode.value && !props.isHydrating) {
      try {
        // Upload file to storage
        const { fileMetadata, error } = await nhost.storage.upload({
          file: blob,
          bucketId: 'default',
          options: { public: true },
        })

        if (error) {
          console.error('Photo upload failed:', error)
          tempPhoto.uploading = false
          tempPhoto.error = 'Upload failed'
          continue
        }

        const url = nhost.storage.getPublicUrl({ fileId: fileMetadata.id })

        // Save to database
        const result = await piecesStore.addImage({
          piece_id: props.pieceId,
          file_id: fileMetadata.id,
          url,
          stage: tempPhoto.stage,
          notes: tempPhoto.notes,
          is_main: tempPhoto.is_main,
        })

        // Update the photo with database info
        const updatedPhoto = {
          ...tempPhoto,
          id: result.id,
          url: url,
          uploading: false,
          error: null,
        }

        // Replace temp photo with saved photo
        const photoIndex = photos.value.findIndex((p) => p.tempId === tempPhoto.tempId)
        if (photoIndex !== -1) {
          photos.value[photoIndex] = updatedPhoto
          emit('update:modelValue', [...photos.value])
        }

        showAutoSaveToast('Photo uploaded successfully!')
      } catch (error) {
        console.error('[PhotoGalleryEditor] Failed to save photo to database:', error)
        tempPhoto.uploading = false
        tempPhoto.error = 'Save failed'
        showAutoSaveToast('Photo upload failed', 'negative')
      }
    }
  }
}

/* ---------- Local-only edits ---------- */
async function setMain(id) {
  // Update local state first
  photos.value = photos.value.map((p) => {
    const key = p.tempId || p.id
    return { ...p, is_main: key === id }
  })
  emit('update:modelValue', [...photos.value])

  // Update database for saved photos
  const photoToUpdate = photos.value.find((p) => (p.tempId || p.id) === id)
  if (photoToUpdate && photoToUpdate.id && !photoToUpdate.tempId) {
    try {
      // First, set all photos to not main
      for (const photo of photos.value) {
        if (photo.id && !photo.tempId && photo.id !== photoToUpdate.id) {
          await piecesStore.updateImage(photo.id, { is_main: false })
        }
      }
      // Then set the selected photo as main
      await piecesStore.updateImage(photoToUpdate.id, { is_main: true })
      console.log('Updated main photo in database:', photoToUpdate.id)
    } catch (error) {
      console.error('Failed to update main photo in database:', error)
    }
  }
}

async function removePhoto(id) {
  // Delete from backend if it's a saved photo
  if (!id.toString().startsWith('ph_')) {
    try {
      await piecesStore.deleteImage(id)
    } catch (err) {
      console.error('Failed to delete from backend', err)
    }
  }

  let updated = photos.value.filter((p) => (p.tempId || p.id) !== id)

  // If no main left, pick the most recent one
  if (updated.length && !updated.some((p) => p.is_main)) {
    // Pick the most recent by created_at if present, otherwise tempId timestamp
    const mostRecent = [...updated].sort((a, b) => {
      if (a.created_at && b.created_at) {
        return new Date(b.created_at) - new Date(a.created_at)
      }
      const aTime = a.tempId ? parseInt(a.tempId.split('_')[1], 36) : 0
      const bTime = b.tempId ? parseInt(b.tempId.split('_')[1], 36) : 0
      return bTime - aTime
    })[0]

    updated = updated.map((p) =>
      (p.tempId || p.id) === (mostRecent.tempId || mostRecent.id)
        ? { ...p, is_main: true }
        : { ...p, is_main: false },
    )

    // Persist new main if it's a saved photo
    if (mostRecent.id) {
      try {
        await piecesStore.updateImage(mostRecent.id, { is_main: true })
      } catch (err) {
        console.error('Failed to update new main photo', err)
      }
    }
  }

  photos.value = updated
  emit('update:modelValue', [...photos.value])
}

/* ---------- Auto-save photo field changes ---------- */
async function updatePhotoField(photo, field, value) {
  // Update local state first
  const photoIndex = photos.value.findIndex(
    (p) => (p.tempId || p.id) === (photo.tempId || photo.id),
  )
  if (photoIndex !== -1) {
    photos.value[photoIndex] = { ...photos.value[photoIndex], [field]: value }
    emit('update:modelValue', [...photos.value])
  }

  // Auto-save to database if photo has ID (is saved) and pieceId is provided
  if (photo.id && isAutoSaveMode.value && !props.isHydrating) {
    try {
      await piecesStore.updateImage(photo.id, { [field]: value })
      showAutoSaveToast('Photo updated')
    } catch (error) {
      console.error('[PhotoGalleryEditor] Failed to update photo field in database:', error)
    }
  }
}
</script>

<style scoped>
.drop-area {
  border: 1px dashed #bbb;
  border-radius: 8px;
  padding: 12px;
  text-align: center;
  cursor: pointer;
}
.rounded-borders {
  border-radius: 6px;
}

.rounded-borders {
  border-radius: 6px;
}
.drop-inline {
  border: 1px dashed #bbb;
  border-radius: 6px;
  padding: 4px 8px;
  cursor: pointer;
}
</style>
