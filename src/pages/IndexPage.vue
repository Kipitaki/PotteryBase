<template>
  <q-layout view="lHh Lpr lFf">
    <!-- Header -->
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-avatar square size="50px" class="q-mr-sm">
          <img :src="logoUrl" alt="PotteryBase logo" style="object-fit: contain" />
        </q-avatar>
        <q-toolbar-title class="text-weight-bold">Pottery Base</q-toolbar-title>

        <q-space />
        <q-btn flat round dense icon="search" @click="onSearchClick" />
        <q-btn flat round dense icon="favorite_border" />
        <q-btn
          unelevated
          color="secondary"
          icon="add"
          label="Add piece"
          class="q-ml-sm"
          @click="onAddClick"
        />

        <!-- 👇 User dropdown -->
        <user-dropdown />
      </q-toolbar>
    </q-header>

    <!-- Page -->
    <q-page padding class="bg-grey-1">
      <!-- Hero -->
      <q-card class="rounded-borders q-pa-lg q-mb-xl shadow-4" :style="heroGradientStyle">
        <div class="text-h4 text-weight-bold text-white q-mb-xs">
          Track your pieces. Share your glazes.
        </div>
        <div class="text-body1 text-white q-mb-md">
          From lump to kiln, keep every stage in one place.
        </div>
        <div class="row q-gutter-sm">
          <q-btn
            unelevated
            color="secondary"
            icon="palette"
            label="Browse glazes"
            disable
            class="future-feature"
          />
          <q-btn
            outline
            color="white"
            text-color="white"
            icon="photo_library"
            label="Explore gallery"
            disable
            class="future-feature"
          />
          <q-btn
            outline
            color="white"
            text-color="white"
            icon="view_kanban"
            label="Go to Shelf"
            @click="router.push({ name: 'shelf' })"
          />
        </div>
      </q-card>

      <!-- Your Pieces -->
      <template v-if="isAuth">
        <div class="row items-center q-mb-md">
          <div class="text-h6 text-weight-bold col">Your pieces</div>
          <q-btn
            flat
            dense
            icon="view_kanban"
            label="Go to Shelf"
            @click="router.push({ name: 'shelf' })"
          />
        </div>

        <div class="row q-col-gutter-md q-mb-xl">
          <template v-if="!userPieces.length && loading">
            <q-spinner size="30px" color="primary" class="q-ma-md" />
          </template>

          <template v-else-if="userPieces.length">
            <template v-for="p in userPieces" :key="p.id">
              <shelf-piece-card
                v-if="p?.id"
                :piece="p"
                :subtitle="''"
                class="col-12 col-sm-6 col-md-3 col-lg-2"
              />
            </template>
          </template>

          <template v-else>
            <div class="col-12 text-center text-grey q-mt-md">
              No pieces yet. Click <b>Add piece</b> to get started!
            </div>
          </template>
        </div>
      </template>

      <!-- Community Pieces -->
      <div class="row items-center q-mb-md">
        <div class="text-h6 text-weight-bold col">Community pieces</div>
      </div>

      <div class="row q-col-gutter-md q-mb-xl">
        <template v-if="!communityPieces.length && loading">
          <q-spinner size="30px" color="primary" class="q-ma-md" />
        </template>

        <template v-else-if="communityPieces.length">
          <template v-for="p in communityPieces" :key="p.id">
            <shelf-piece-card
              v-if="p?.id"
              :piece="p"
              :subtitle="''"
              class="col-12 col-sm-6 col-md-3 col-lg-2"
            />
          </template>
        </template>

        <template v-else>
          <div class="col-12 text-center text-grey q-mt-md">
            No public pieces in the community yet.
          </div>
        </template>
      </div>

      <!-- Stats + Activity -->
      <div class="row q-col-gutter-lg q-mt-xl">
        <div class="col-12 col-md-4">
          <q-card bordered class="rounded-borders shadow-2 future-feature-card">
            <q-card-section>
              <div class="text-subtitle1 text-weight-bold q-mb-xs">Your week</div>
              <div class="text-caption text-grey-7 q-mb-md">Formed, trimmed, glazed, and fired</div>
              <div class="row justify-around text-h5">
                <div class="column items-center">
                  <div>{{ stats.formed }}</div>
                  <div class="text-caption text-grey-7">Formed</div>
                </div>
                <div class="column items-center">
                  <div>{{ stats.trimmed }}</div>
                  <div class="text-caption text-grey-7">Trimmed</div>
                </div>
                <div class="column items-center">
                  <div>{{ stats.glazed }}</div>
                  <div class="text-caption text-grey-7">Glazed</div>
                </div>
                <div class="column items-center">
                  <div>{{ stats.fired }}</div>
                  <div class="text-caption text-grey-7">Fired</div>
                </div>
              </div>
            </q-card-section>
          </q-card>
        </div>

        <div class="col-12 col-md-8">
          <q-card bordered class="rounded-borders shadow-2 future-feature-card">
            <q-card-section>
              <div class="text-subtitle1 text-weight-bold q-mb-xs">Recent activity</div>
              <div class="text-caption text-grey-7 q-mb-md">Populated from fixtures and store</div>
              <q-list separator>
                <q-item v-for="a in activity" :key="a.id">
                  <q-item-section avatar>
                    <q-avatar rounded>
                      <img :src="a.avatar" alt="avatar" />
                    </q-avatar>
                  </q-item-section>
                  <q-item-section>
                    <q-item-label>
                      <span class="text-weight-medium">{{ a.user }}</span>
                      {{ ' ' + a.action + ' ' }}
                      <span class="text-weight-medium">{{ a.target }}</span>
                    </q-item-label>
                    <q-item-label caption>{{ a.time }}</q-item-label>
                  </q-item-section>
                  <q-item-section side>
                    <q-btn flat round dense icon="more_vert" />
                  </q-item-section>
                </q-item>
              </q-list>
            </q-card-section>
          </q-card>
        </div>
      </div>
    </q-page>

    <!-- Footer -->
    <q-footer class="bg-primary text-white">
      <div class="row items-center justify-between full-width q-px-md q-py-sm">
        <div class="text-caption">© {{ new Date().getFullYear() }} Pottery Base</div>
        <div>
          <q-btn flat dense no-caps label="About" class="text-white" />
          <q-btn flat dense no-caps label="Contact" class="text-white" />
          <q-btn flat dense no-caps label="Privacy" class="text-white" />
        </div>
      </div>
    </q-footer>
  </q-layout>
</template>

<script setup>
import { computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { usePiecesStore } from 'src/stores/pieces'
import { usePotteryStore } from 'src/stores/pottery-store'
import ShelfPieceCard from 'src/components/ShelfPieceCard.vue'
import UserDropdown from 'src/components/UserDropdown.vue'
import logoUrl from 'assets/Potterybaselogo.svg'
import { useAuthenticationStatus, useUserData } from '@nhost/vue'

// --- Stores ---
const piecesStore = usePiecesStore()
const pottery = usePotteryStore()
const router = useRouter()

// --- Nhost auth ---
const { isAuthenticated } = useAuthenticationStatus()
const user = useUserData()

// --- Computeds ---
const isAuth = computed(() => isAuthenticated.value)
const allPieces = computed(() => piecesStore.all?.value ?? [])
const loading = computed(() => piecesStore.loading)

const userPieces = computed(() => {
  if (!user.value) return []
  return allPieces.value.filter((p) => p.owner_id === user.value.id)
})

// Community = all other pieces (not owned by this user)
const communityPieces = computed(() => {
  var userid = -1
  if (!user.value) userid = -1
  else userid = user.value.id
  return allPieces.value.filter((p) => p.owner_id !== userid)
})

const stats = computed(() => pottery.stats)
const activity = computed(() => pottery.activity)

// --- Debug logs ---
watch(isAuth, (val) => {
  console.log('[Auth] isAuth changed →', val, 'user:', user.value)
})
watch(loading, (val) => {
  console.log('[Pieces] loading →', val)
})
watch(
  () => piecesStore.all?.value,
  (val) => {
    console.log('[Pieces] result changed →', val)
  },
)
watch(
  () => piecesStore.error?.value,
  (err) => {
    if (err) console.error('[Pieces] error →', err)
  },
)

// --- Handlers ---
function onSearchClick() {
  console.log('search clicked')
}
function onAddClick() {
  router.push({ name: 'addpiece' })
}

const heroGradientStyle =
  'background: linear-gradient(135deg, #7A5E51 0%, #6B8F71 100%); color: white;'
</script>

<style scoped>
.rounded-borders {
  border-radius: 16px;
}

/* Future feature styling */
.future-feature {
  opacity: 0.6;
  cursor: not-allowed;
}

.future-feature-card {
  opacity: 0.7;
  background: linear-gradient(135deg, #f5f5f5 0%, #e8e8e8 100%);
  border: 2px dashed #ccc;
  position: relative;
}

.future-feature-card::before {
  content: 'Coming Soon';
  position: absolute;
  top: 8px;
  right: 8px;
  background: #ff9800;
  color: white;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 10px;
  font-weight: bold;
  z-index: 1;
}
</style>
