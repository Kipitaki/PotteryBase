<template>
  <div class="q-pa-md flex flex-center column">
    <q-card class="q-pa-lg" style="max-width: 400px; width: 100%">
      <q-card-section>
        <div class="text-h6 text-center">
          {{ isLoginMode ? 'Login to' : 'Create Account for' }} PotteryBase
        </div>
      </q-card-section>

      <q-banner class="bg-secondary text-white" v-if="error_msg">
        {{ error_msg }}
      </q-banner>

      <q-banner class="bg-positive text-white" v-if="success_msg">
        {{ success_msg }}
      </q-banner>

      <q-card-section>
        <q-input
          v-model="email"
          label="Email"
          type="email"
          filled
          class="q-mb-md"
          :rules="[(val) => !!val || 'Email is required']"
        />
        <q-input
          v-model="password"
          label="Password"
          type="password"
          filled
          class="q-mb-md"
          :rules="[
            (val) => !!val || 'Password is required',
            (val) => val.length >= 6 || 'Password must be at least 6 characters',
          ]"
        />
        <q-input
          v-if="!isLoginMode"
          v-model="confirmPassword"
          label="Confirm Password"
          type="password"
          filled
          class="q-mb-md"
          :rules="[
            (val) => !!val || 'Please confirm your password',
            (val) => val === password || 'Passwords do not match',
          ]"
        />
      </q-card-section>

      <q-card-actions align="center" class="q-gutter-md">
        <q-btn
          color="primary"
          :label="isLoginMode ? 'Login' : 'Create Account'"
          @click="isLoginMode ? handleLogin() : handleRegister()"
          :loading="loading"
        />
      </q-card-actions>

      <q-card-section class="text-center">
        <q-btn
          flat
          :label="isLoginMode ? 'Need an account? Sign up' : 'Already have an account? Login'"
          @click="toggleMode"
          color="secondary"
        />
        <div v-if="isLoginMode" class="q-mt-md">
          <q-btn
            flat
            label="Reset Password"
            @click="showPasswordResetModal = true"
            color="primary"
            size="sm"
          />
        </div>
      </q-card-section>
    </q-card>

    <!-- Password Reset Modal -->
    <q-dialog v-model="showPasswordResetModal">
      <q-card style="min-width: 400px">
        <q-card-section>
          <div class="text-h6">Reset Password</div>
        </q-card-section>

        <q-card-section>
          <div class="text-body2 q-mb-md">
            Enter your email and new password to reset your account.
          </div>

          <q-input
            v-model="resetEmail"
            label="Email"
            type="email"
            filled
            class="q-mb-md"
            :rules="[(val) => !!val || 'Email is required']"
          />

          <q-input
            v-model="resetPassword"
            label="New Password"
            type="password"
            filled
            class="q-mb-md"
            :rules="[
              (val) => !!val || 'Password is required',
              (val) => val.length >= 6 || 'Password must be at least 6 characters',
            ]"
          />

          <q-input
            v-model="resetConfirmPassword"
            label="Confirm New Password"
            type="password"
            filled
            class="q-mb-md"
            :rules="[
              (val) => !!val || 'Please confirm your password',
              (val) => val === resetPassword || 'Passwords do not match',
            ]"
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancel" @click="closePasswordResetModal" />
          <q-btn
            color="primary"
            label="Reset Password"
            @click="handlePasswordReset"
            :loading="resetLoading"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { nhost } from 'boot/nhost' // ✅ single source

const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const error_msg = ref('')
const success_msg = ref('')
const loading = ref(false)
const isLoginMode = ref(true)
const router = useRouter()

// Password reset modal state
const showPasswordResetModal = ref(false)
const resetEmail = ref('')
const resetPassword = ref('')
const resetConfirmPassword = ref('')
const resetLoading = ref(false)

function toggleMode() {
  isLoginMode.value = !isLoginMode.value
  error_msg.value = ''
  success_msg.value = ''
  email.value = ''
  password.value = ''
  confirmPassword.value = ''
}

async function handleLogin() {
  error_msg.value = ''
  success_msg.value = ''
  loading.value = true

  try {
    const { session, error } = await nhost.auth.signIn({
      email: email.value,
      password: password.value,
    })

    if (error) {
      error_msg.value = error.message
    } else if (session) {
      router.push({ name: 'home' })
    }
  } catch (err) {
    error_msg.value = err.message || 'Unexpected login error'
  } finally {
    loading.value = false
  }
}

async function handleRegister() {
  error_msg.value = ''
  success_msg.value = ''
  loading.value = true

  // Validate passwords match
  if (password.value !== confirmPassword.value) {
    error_msg.value = 'Passwords do not match'
    loading.value = false
    return
  }

  // Validate password length
  if (password.value.length < 6) {
    error_msg.value = 'Password must be at least 6 characters long'
    loading.value = false
    return
  }

  try {
    const { session, error } = await nhost.auth.signUp({
      email: email.value,
      password: password.value,
    })

    if (error) {
      error_msg.value = error.message
    } else if (session) {
      // User is automatically signed in after successful registration
      success_msg.value = 'Account created successfully! Welcome to PotteryBase!'
      setTimeout(() => {
        router.push({ name: 'home' })
      }, 2000)
    } else {
      // Email verification might be required
      success_msg.value =
        'Account created! Please check your email to verify your account before logging in.'
      isLoginMode.value = true
    }
  } catch (err) {
    error_msg.value = err.message || 'Unexpected registration error'
  } finally {
    loading.value = false
  }
}

function closePasswordResetModal() {
  showPasswordResetModal.value = false
  resetEmail.value = ''
  resetPassword.value = ''
  resetConfirmPassword.value = ''
  error_msg.value = ''
  success_msg.value = ''
}

async function handlePasswordReset() {
  // Validate inputs
  if (!resetEmail.value) {
    error_msg.value = 'Please enter your email address'
    return
  }

  if (!resetPassword.value) {
    error_msg.value = 'Please enter a new password'
    return
  }

  if (resetPassword.value !== resetConfirmPassword.value) {
    error_msg.value = 'Passwords do not match'
    return
  }

  if (resetPassword.value.length < 6) {
    error_msg.value = 'Password must be at least 6 characters long'
    return
  }

  resetLoading.value = true
  error_msg.value = ''
  success_msg.value = ''

  try {
    // First, try to create a new account
    const { session, error } = await nhost.auth.signUp({
      email: resetEmail.value,
      password: resetPassword.value,
    })

    if (session) {
      // New account created successfully
      success_msg.value = 'Account created successfully! You can now log in with your new password.'
      closePasswordResetModal()
    } else if (error && (error.message.includes('already') || error.message.includes('exists'))) {
      // Account exists - try to update the password by signing in and changing it
      try {
        // Try to sign in with a dummy password to get the user session
        const { session: signInSession } = await nhost.auth.signIn({
          email: resetEmail.value,
          password: 'temp_password_123',
        })

        if (signInSession) {
          // User is signed in, now change the password
          const { error: changeError } = await nhost.auth.changePassword({
            newPassword: resetPassword.value,
          })

          if (changeError) {
            error_msg.value =
              'Unable to reset password. Please try creating a new account with a different email.'
          } else {
            success_msg.value =
              'Password reset successfully! You can now log in with your new password.'
            closePasswordResetModal()
          }
        } else {
          // Sign in failed, account exists but we can't access it
          error_msg.value =
            'Account exists but password cannot be reset without current password. Please create a new account with a different email.'
        }
      } catch {
        error_msg.value =
          'Account exists but password cannot be reset. Please create a new account with a different email.'
      }
    } else if (error) {
      error_msg.value = error.message
    } else {
      // Email verification might be required
      success_msg.value =
        'Account created! Please check your email to verify your account before logging in.'
    }
  } catch (err) {
    error_msg.value = err.message || 'Unexpected error setting password'
  } finally {
    resetLoading.value = false
  }
}
</script>
