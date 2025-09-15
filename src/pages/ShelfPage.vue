<template>
  <q-page padding>
    <div class="row items-center justify-between q-mb-md">
      <div class="text-h5">What's on the Shelf</div>
      <q-badge v-if="shelf.length" color="primary" outline>{{ shelf.length }} piece(s)</q-badge>
    </div>

    <div v-if="!shelf.length" class="text-grey-7">
      Nothing on the shelf yet. Save a piece with a Fired date and no Sold status.
    </div>

    <div class="row q-col-gutter-xs">
      <div v-for="p in shelf" :key="p.id" class="col-12 col-sm-6 col-md-4 col-lg-3">
        <shelf-piece-card :piece="p" :subtitle="firedLabel(p)" />
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { computed } from 'vue'
import { usePiecesStore } from 'src/stores/pieces'
import ShelfPieceCard from 'src/components/ShelfPieceCard.vue'

const pieces = usePiecesStore()
const shelf = computed(() => pieces.onShelf)

function firedLabel(p) {
  const d = p.stageDates?.fired
  return d ? `Fired on ${d}` : 'Not fired'
}
</script>
