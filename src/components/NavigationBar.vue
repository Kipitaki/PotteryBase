<template>
  <q-header elevated class="bg-primary text-white">
    <q-toolbar class="q-px-lg">
      <!-- Logo + Title (left aligned) -->
      <q-avatar square size="42px" class="q-mr-sm cursor-pointer" @click="goHome">
        <q-icon name="ceramic" size="24px" />
      </q-avatar>
      <q-toolbar-title class="text-weight-bold text-h6">Pottery Base</q-toolbar-title>

      <q-space />

      <!-- Right-side nav actions -->
      <div class="row items-center q-gutter-sm">
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

const route = useRoute()
const router = useRouter()

const activeTab = computed(() => {
  const path = route.path
  if (path === '/' || path === '/home') return 'home'
  if (path.startsWith('/shelf')) return 'shelf'
  if (path.startsWith('/add')) return 'add'
  return ''
})

function goHome() {
  router.push('/')
}

function goShelf() {
  router.push('/shelf')
}

function onSearchClick() {
  console.log('Search clicked')
}

function onAddClick() {
  router.push('/add')
}
</script>

<style scoped>
/* Optional: highlight active nav button */
.nav-btn-active {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  font-weight: 600;
  transform: translateY(-1px);
}
</style>
