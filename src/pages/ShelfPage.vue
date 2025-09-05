<template>
  <q-page padding>
    <div class="row items-center justify-between q-mb-md">
      <div class="text-h5">What's on the Shelf</div>
      <q-badge v-if="shelf.length" color="primary" outline>{{ shelf.length }} piece(s)</q-badge>
    </div>

    <div v-if="!shelf.length" class="text-grey-7">
      Nothing on the shelf yet. Save a piece with a Fired date and no Sold status.
    </div>

    <div class="row q-col-gutter-md">
      <div v-for="p in shelf" :key="p.id" class="col-12 col-sm-6 col-md-4 col-lg-3">
        <q-card flat bordered>
          <q-img :src="thumb(p)" ratio="4/3" :alt="p.title || 'Piece'" />
          <q-card-section>
            <div class="text-subtitle1 ellipsis">{{ p.title || 'Untitled' }}</div>
            <div class="text-caption text-grey-7">{{ firedLabel(p) }}</div>
          </q-card-section>
          <q-card-actions align="right">
            <q-btn flat dense icon="visibility" :to="`/piece/${p.id}`" label="Open" />
          </q-card-actions>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { computed } from 'vue'
import { usePiecesStore } from 'src/stores/pieces'

const pieces = usePiecesStore()
const shelf = computed(() => pieces.onShelf)

function thumb(p) {
  return p.photos?.[0]?.url || 'https://via.placeholder.com/800x600?text=Pottery'
}
function firedLabel(p) {
  const d = p.stageDates?.fired
  return d ? `Fired on ${d}` : 'Not fired'
}
</script>

