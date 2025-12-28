<template>
  <q-page class="shop-page q-pa-md">
    <div v-if="loading" class="flex flex-center q-pa-xl">
      <q-spinner-dots size="3em" color="primary" />
    </div>

    <div v-else-if="!profile" class="flex flex-center column q-pa-xl">
      <q-icon name="store" size="4em" color="grey-5" class="q-mb-md" />
      <div class="text-h6 text-grey-7">Shop not found</div>
      <div class="text-caption text-grey-6 q-mt-sm">
        This shop page doesn't exist or has been disabled.
      </div>
    </div>

    <div v-else>
      <!-- Shop Header -->
      <div class="q-mb-lg">
        <div class="text-h4 text-weight-bold q-mb-xs">
          {{ profile.shop_name || profile.display_name || 'Shop' }}
        </div>
        <div v-if="profile.display_name && profile.shop_name" class="text-body2 text-grey-7">
          by {{ profile.display_name }}
        </div>
      </div>

      <!-- Shop Items -->
      <div v-if="pieces.length === 0" class="flex flex-center column q-pa-xl">
        <q-icon name="inventory_2" size="4em" color="grey-5" class="q-mb-md" />
        <div class="text-h6 text-grey-7">No items available</div>
        <div class="text-caption text-grey-6 q-mt-sm">
          This shop doesn't have any items for sale yet.
        </div>
      </div>

      <div v-else class="row q-col-gutter-md">
        <div
          v-for="piece in pieces"
          :key="piece.id"
          class="col-12 col-sm-6 col-md-4 col-lg-3"
        >
          <q-card class="piece-card cursor-pointer" @click="viewPiece(piece.id)">
            <q-img
              v-if="piece.piece_images?.[0]?.url"
              :src="piece.piece_images[0].url"
              style="height: 200px"
              fit="cover"
            >
              <div class="absolute-top-right q-pa-xs">
                <q-chip
                  v-if="!piece.in_stock"
                  color="negative"
                  text-color="white"
                  size="sm"
                  label="Out of Stock"
                />
              </div>
            </q-img>
            <q-card-section>
              <div class="text-h6 text-weight-medium">{{ piece.title || 'Untitled' }}</div>
              <div v-if="piece.price" class="text-h6 text-primary text-weight-bold q-mt-sm">
                ${{ formatPrice(piece.price) }}
              </div>
              <div v-else class="text-body2 text-grey-6 q-mt-sm">Price not set</div>
            </q-card-section>
            <q-card-actions>
              <q-btn
                flat
                label="View Details"
                color="primary"
                @click.stop="viewPiece(piece.id)"
              />
              <q-space />
              <q-btn
                v-if="piece.is_for_sale && piece.in_stock"
                color="primary"
                label="Add to Cart"
                @click.stop="addToCart(piece.id)"
              />
            </q-card-actions>
          </q-card>
        </div>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import gql from 'graphql-tag'
import { provideApolloClient, useQuery } from '@vue/apollo-composable'
import { apolloClient } from 'boot/apollo'
import { useCartStore } from 'src/stores/cart'

provideApolloClient(apolloClient)

const route = useRoute()
const router = useRouter()
const $q = useQuasar()
const cartStore = useCartStore()

const shopSlug = computed(() => route.params.slug)

const PROFILE_BY_SLUG = gql`
  query ProfileBySlug($shop_slug: String!) {
    potterbase_profiles(where: { shop_slug: { _eq: $shop_slug }, shop_enabled: { _eq: true } }, limit: 1) {
      id
      display_name
      shop_name
      shop_slug
      shop_enabled
    }
  }
`

const PIECES_BY_OWNER = gql`
  query PiecesByOwner($owner_id: UUID!) {
    potterbase_piece(
      where: { owner_id: { _eq: $owner_id }, is_for_sale: { _eq: true } }
      order_by: { created_at: desc }
    ) {
      id
      title
      price
      is_for_sale
      in_stock
      owner_id
      piece_images(where: { is_main: { _eq: true } }, limit: 1) {
        url
      }
    }
  }
`

const { result: profileResult, loading: profileLoading } = useQuery(
  PROFILE_BY_SLUG,
  () => ({ shop_slug: shopSlug.value }),
  () => ({ enabled: !!shopSlug.value })
)

const profile = computed(() => profileResult.value?.potterbase_profiles?.[0])

const { result: piecesResult, loading: piecesLoading } = useQuery(
  PIECES_BY_OWNER,
  () => ({ owner_id: profile.value?.id }),
  () => ({ enabled: !!profile.value?.id })
)

const pieces = computed(() => piecesResult.value?.potterbase_piece || [])
const loading = computed(() => profileLoading.value || piecesLoading.value)

function formatPrice(price) {
  return price.toFixed(2)
}

function viewPiece(pieceId) {
  router.push({ name: 'viewpiece', query: { id: pieceId } })
}

async function addToCart(pieceId) {
  try {
    await cartStore.addToCart(pieceId, 1)
    $q.notify({
      type: 'positive',
      message: 'Added to cart',
      position: 'top',
      timeout: 2000,
    })
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Failed to add to cart',
      position: 'top',
    })
  }
}
</script>

<style scoped>
.shop-page {
  max-width: 1400px;
  margin: 0 auto;
}

.piece-card {
  transition: transform 0.2s;
}

.piece-card:hover {
  transform: translateY(-4px);
}
</style>

