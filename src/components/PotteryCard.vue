<template>
  <q-card clickable @click="$emit('view', item)" class="q-mb-md">
    <q-img :src="resolveSrc(item)" ratio="4/3" :img-style="{ objectFit: 'cover' }">
      <template #error>
        <div class="column items-center justify-center text-grey-6 q-pa-md">
          <q-icon name="image_not_supported" size="32px" class="q-mb-sm" />
          <div class="text-caption">No image</div>
        </div>
      </template>
      <!-- TEMP: force-show image -->
      <div
        style="
          position: relative;
          width: 100%;
          aspect-ratio: 4/3;
          overflow: hidden;
          border-radius: 12px;
        "
      >
        <img
          :src="item?.image && item.image.length ? item.image : placeholder(item?.id)"
          style="width: 100%; height: 100%; object-fit: cover; display: block"
          alt=""
        />
      </div>
      <div v-if="showStageChip && item?.stage" class="absolute-top-left q-ma-sm">
        <q-chip size="sm" color="primary" text-color="white" square>{{ item.stage }}</q-chip>
      </div>
    </q-img>

    <q-card-section>
      <div class="row items-start justify-between no-wrap">
        <div class="col">
          <div class="text-subtitle1">{{ item?.name || 'Untitled' }}</div>
          <div class="text-caption text-grey-7 ellipsis-2-lines">
            {{ item?.description }}
          </div>
        </div>
        <div v-if="showLike" class="col-auto">
          <q-btn
            flat
            round
            dense
            :icon="(likedIds || []).includes(item?.id) ? 'favorite' : 'favorite_border'"
            @click.stop="$emit('toggle-like', item)"
          />
        </div>
      </div>

      <div v-if="showTags && item?.tags?.length" class="q-mt-sm">
        <q-chip
          v-for="t in item.tags"
          :key="t"
          size="sm"
          outline
          color="grey-7"
          class="q-mr-xs q-mb-xs"
        >
          {{ t }}
        </q-chip>
      </div>
    </q-card-section>

    <q-separator v-if="showActions" />

    <q-card-actions v-if="showActions" align="between">
      <q-btn flat icon="visibility" label="View" @click.stop="$emit('view', item)" />
      <q-btn flat icon="bookmark_add" label="Save" @click.stop="$emit('save', item)" />
    </q-card-actions>
  </q-card>
</template>

<script setup>
defineProps({
  item: { type: Object, required: true },
  showStageChip: { type: Boolean, default: true },
  showTags: { type: Boolean, default: true },
  showActions: { type: Boolean, default: true },
  showLike: { type: Boolean, default: true },
  likedIds: { type: Array, default: () => [] },
})

defineEmits(['view', 'save', 'toggle-like'])

const placeholder = (n) => `https://picsum.photos/seed/pottery-${n || 'x'}/800/600`
const resolveSrc = (it) =>
  it?.image && String(it.image).length > 0 ? it.image : placeholder(it?.id)
</script>

<style scoped>
.ellipsis-2-lines {
  display: -webkit-box;
  -webkit-line-clamp: 2; /* Safari/Chrome */
  line-clamp: 2; /* Standard (not yet widely supported) */
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
