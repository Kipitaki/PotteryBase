<template>
  <div class="row q-col-gutter-lg">
    <div v-for="it in items" :key="it.id" class="col-12 col-sm-6 col-md-4">
      <PotteryCard
        :item="it"
        :dense="dense"
        :show-stage-chip="showStageChip"
        :show-tags="showTags"
        :show-actions="showActions"
        :show-like="showLike"
        :liked-ids="likedIds"
        @view="$emit('view', $event)"
        @save="$emit('save', $event)"
        @toggle-like="$emit('toggle-like', $event)"
      />
    </div>

    <!-- Empty state -->
    <div v-if="!items?.length" class="col-12">
      <q-banner inline-actions rounded class="bg-grey-2">
        No pieces yet. Add your first one to get started.
        <template #action>
          <q-btn color="secondary" label="Add piece" icon="add" flat />
        </template>
      </q-banner>
    </div>
  </div>
</template>

<script setup>
import PotteryCard from './PotteryCard.vue'

defineProps({
  items: { type: Array, required: true },
  dense: { type: Boolean, default: false },
  showStageChip: { type: Boolean, default: true },
  showTags: { type: Boolean, default: true },
  showActions: { type: Boolean, default: true },
  showLike: { type: Boolean, default: true },
  likedIds: { type: Array, default: () => [] },
})

defineEmits(['view', 'save', 'toggle-like'])
</script>
