<template>
  <q-header elevated class="bg-primary text-white">
    <q-toolbar class="q-px-sm q-px-md-lg">
      <!-- Logo + Title (left aligned) -->
      <q-avatar
        square
        :size="$q.screen.lt.md ? '32px' : '42px'"
        class="q-mr-sm cursor-pointer"
        @click="goHome"
      >
        <q-icon name="ceramic" :size="$q.screen.lt.md ? '18px' : '24px'" />
      </q-avatar>
      <q-toolbar-title
        class="text-weight-bold"
        :class="$q.screen.lt.md ? 'text-subtitle1' : 'text-h6'"
      >
        Pottery Base
      </q-toolbar-title>

      <q-space />

      <!-- Desktop nav actions -->
      <div class="row items-center q-gutter-sm gt-xs">
        <!-- Search -->
        <q-btn flat dense round icon="search" @click="onSearchClick" />

        <!-- Favorites -->
        <q-btn flat dense round icon="favorite_border" />

        <!-- Home -->
        <q-btn
          unelevated
          color="secondary"
          icon="home"
          label="Home"
          @click="goHome"
          no-caps
          :class="activeTab === 'home' ? 'nav-btn-active' : ''"
        />

        <!-- Shelf -->
        <q-btn
          unelevated
          color="secondary"
          icon="inventory_2"
          label="Shelf"
          @click="goShelf"
          no-caps
          :class="activeTab === 'shelf' ? 'nav-btn-active' : ''"
        />

        <!-- Glazes -->
        <q-btn
          unelevated
          color="secondary"
          icon="palette"
          label="Glazes"
          @click="goGlazes"
          no-caps
          :class="activeTab === 'glazes' ? 'nav-btn-active' : ''"
        />

        <!-- Add Piece -->
        <q-btn
          unelevated
          color="secondary"
          icon="add"
          label="Add Piece"
          @click="onAddClick"
          no-caps
          :class="activeTab === 'add' ? 'nav-btn-active' : ''"
        />

        <!-- Bandanas (Admin only) -->
        <q-btn
          v-if="isAdmin"
          unelevated
          color="purple"
          icon="inventory"
          label="Bandanas"
          @click="goBandanas"
          no-caps
          :class="activeTab === 'bandanas' ? 'nav-btn-active' : ''"
        />

        <!-- User dropdown -->
        <user-dropdown />
      </div>

      <!-- Mobile nav actions -->
      <div class="row items-center q-gutter-xs xs">
        <!-- Search -->
        <q-btn flat dense round icon="search" size="sm" @click="onSearchClick" />

        <!-- Favorites -->
        <q-btn flat dense round icon="favorite_border" size="sm" />

        <!-- Home -->
        <q-btn
          flat
          dense
          round
          icon="home"
          size="sm"
          @click="goHome"
          :class="activeTab === 'home' ? 'nav-btn-active-mobile' : ''"
        />

        <!-- Shelf -->
        <q-btn
          flat
          dense
          round
          icon="inventory_2"
          size="sm"
          @click="goShelf"
          :class="activeTab === 'shelf' ? 'nav-btn-active-mobile' : ''"
        />

        <!-- Glazes -->
        <q-btn
          flat
          dense
          round
          icon="palette"
          size="sm"
          @click="goGlazes"
          :class="activeTab === 'glazes' ? 'nav-btn-active-mobile' : ''"
        />

        <!-- Add Piece -->
        <q-btn
          unelevated
          color="secondary"
          icon="add"
          size="sm"
          round
          @click="onAddClick"
          :class="activeTab === 'add' ? 'nav-btn-active-mobile' : ''"
        />

        <!-- Bandanas (Admin only) -->
        <q-btn
          v-if="isAdmin"
          flat
          dense
          round
          icon="inventory"
          size="sm"
          color="purple"
          @click="goBandanas"
          :class="activeTab === 'bandanas' ? 'nav-btn-active-mobile' : ''"
        />

        <!-- User dropdown -->
        <user-dropdown />
      </div>
    </q-toolbar>
  </q-header>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import UserDropdown from 'src/components/UserDropdown.vue'
import { useAdmin } from 'src/composables/useAdmin'

const route = useRoute()
const router = useRouter()
const { isAdmin } = useAdmin()

const activeTab = computed(() => {
  const path = route.path
  if (path === '/' || path === '/home') return 'home'
  if (path.startsWith('/shelf')) return 'shelf'
  if (path.startsWith('/glazes')) return 'glazes'
  if (path.startsWith('/add')) return 'add'
  if (path.startsWith('/bandanas')) return 'bandanas'
  return ''
})

function goHome() {
  router.push('/')
}

function goShelf() {
  router.push('/shelf')
}

function goGlazes() {
  router.push('/glazes')
}

function goBandanas() {
  router.push('/bandanas')
}

function onSearchClick() {
  console.log('Search clicked')
}

function onAddClick() {
  router.push('/add')
}
</script>

<style scoped>
/* Desktop: highlight active nav button */
.nav-btn-active {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  font-weight: 600;
  transform: translateY(-1px);
}

/* Mobile: highlight active nav button */
.nav-btn-active-mobile {
  background-color: rgba(255, 255, 255, 0.2) !important;
  color: white !important;
}
</style>
