<template>
  <div>
    <!-- If authenticated, show user dropdown -->
    <q-btn-dropdown
      v-if="isAuth"
      flat
      no-caps
      :label="userDisplayName"
      dropdown-icon="arrow_drop_down"
      class="text-white"
    >
      <q-list>
        <q-item clickable v-close-popup @click="goToProfile">
          <q-item-section avatar>
            <q-icon name="account_circle" />
          </q-item-section>
          <q-item-section>
            <q-item-label>Profile</q-item-label>
          </q-item-section>
        </q-item>

        <q-separator />

        <q-item clickable v-close-popup @click="logout">
          <q-item-section avatar>
            <q-icon name="logout" />
          </q-item-section>
          <q-item-section>
            <q-item-label>Logout</q-item-label>
          </q-item-section>
        </q-item>
      </q-list>
    </q-btn-dropdown>

    <!-- If not authenticated, show login button -->
    <q-btn v-else flat color="white" label="Login" icon="login" :to="{ name: 'login' }" />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthenticationStatus, useUserData } from '@nhost/vue'

const router = useRouter()

// Authentication state
const { isAuthenticated } = useAuthenticationStatus()
const user = useUserData()

const isAuth = computed(() => isAuthenticated.value)
const userDisplayName = computed(() => {
  if (!user.value) return 'User'
  return user.value.displayName || user.value.email || 'User'
})

// Actions
function goToProfile() {
  router.push({ name: 'profile' })
}

function logout() {
  router.push({ name: 'logout' })
}
</script>
