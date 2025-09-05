<template>
  <div class="q-pa-md flex flex-center column">
    <q-card class="q-pa-lg" style="max-width: 400px; width: 100%">
      <q-card-section>
        <div class="text-h6 text-center">{{ title }}</div>
      </q-card-section>

      <q-card-section class="text-center">
        <q-spinner-dots v-if="isLoggingOut" color="primary" size="2em" />
        <div v-else-if="loggedOut">
          <q-icon name="check_circle" color="positive" size="3em" class="q-mb-md" />
          <p>You have been successfully logged out.</p>
        </div>
        <div v-else-if="error">
          <q-icon name="error" color="negative" size="3em" class="q-mb-md" />
          <p>{{ error }}</p>
        </div>
      </q-card-section>

      <q-card-actions align="center" v-if="!isLoggingOut">
        <q-btn color="primary" label="Go to Login" @click="goToLogin" />
        <q-btn flat label="Go Home" @click="goToHome" />
      </q-card-actions>
    </q-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { nhost } from 'boot/nhost'

const router = useRouter()
const isLoggingOut = ref(true)
const loggedOut = ref(false)
const error = ref('')

const title = computed(() => {
  if (isLoggingOut.value) return 'Logging out...'
  if (loggedOut.value) return 'Logged out successfully'
  if (error.value) return 'Logout failed'
  return 'Logout'
})

async function performLogout() {
  try {
    const { error: logoutError } = await nhost.auth.signOut()
    
    if (logoutError) {
      error.value = logoutError.message || 'Failed to log out'
    } else {
      loggedOut.value = true
    }
  } catch (err) {
    error.value = err.message || 'Unexpected logout error'
  } finally {
    isLoggingOut.value = false
  }
}

function goToLogin() {
  router.push({ name: 'login' })
}

function goToHome() {
  router.push({ name: 'home' })
}

onMounted(() => {
  performLogout()
})
</script>