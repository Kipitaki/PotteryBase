<template>
  <q-page class="q-pa-md">
    <div class="row justify-center">
      <div class="col-12 col-md-8 col-lg-6">
        <q-card class="q-pa-lg">
          <q-card-section>
            <div class="text-h5 text-center q-mb-lg">Profile</div>

            <!-- Loading state -->
            <div v-if="loading" class="text-center q-pa-lg">
              <q-spinner-dots color="primary" size="2em" />
              <p class="q-mt-md">Loading profile...</p>
            </div>

            <!-- Profile content -->
            <div v-else-if="profile">
              <!-- Profile header -->
              <div class="text-center q-mb-lg">
                <q-avatar size="100px" color="primary" class="q-mb-md">
                  <q-icon name="account_circle" size="60px" />
                </q-avatar>
                <div class="text-h6">{{ profile.display_name || 'User' }}</div>
                <div class="text-caption text-grey">{{ user?.email }}</div>
              </div>

              <!-- Profile information -->
              <q-list>
                <q-item>
                  <q-item-section avatar>
                    <q-icon name="email" />
                  </q-item-section>
                  <q-item-section>
                    <q-item-label>Email</q-item-label>
                    <q-item-label caption>{{ user?.email }}</q-item-label>
                  </q-item-section>
                </q-item>

                <q-item>
                  <q-item-section avatar>
                    <q-icon name="person" />
                  </q-item-section>
                  <q-item-section>
                    <q-item-label>Display Name</q-item-label>
                    <q-item-label caption>{{ profile.display_name }}</q-item-label>
                  </q-item-section>
                </q-item>

                <q-item>
                  <q-item-section avatar>
                    <q-icon name="straighten" />
                  </q-item-section>
                  <q-item-section>
                    <q-item-label>Unit Preference</q-item-label>
                    <q-item-label caption>
                      {{
                        profile.unit_preference === 'metric' ? 'Metric (cm/g)' : 'Imperial (in/lb)'
                      }}
                    </q-item-label>
                  </q-item-section>
                </q-item>

                <q-item>
                  <q-item-section avatar>
                    <q-icon name="calendar_today" />
                  </q-item-section>
                  <q-item-section>
                    <q-item-label>Member Since</q-item-label>
                    <q-item-label caption>{{ formatDate(user?.createdAt) }}</q-item-label>
                  </q-item-section>
                </q-item>

                <q-item v-if="user?.lastSignInAt">
                  <q-item-section avatar>
                    <q-icon name="access_time" />
                  </q-item-section>
                  <q-item-section>
                    <q-item-label>Last Sign In</q-item-label>
                    <q-item-label caption>{{ formatDate(user.lastSignInAt) }}</q-item-label>
                  </q-item-section>
                </q-item>
              </q-list>

              <!-- Account actions -->
              <q-separator class="q-my-lg" />

              <div class="text-center">
                <q-btn
                  color="primary"
                  label="Edit Profile"
                  icon="edit"
                  @click="showEditDialog = true"
                  class="q-mr-md"
                />
                <q-btn
                  outline
                  color="negative"
                  label="Change Password"
                  icon="lock"
                  @click="showPasswordDialog = true"
                />
              </div>
            </div>

            <!-- Error state -->
            <div v-else class="text-center q-pa-lg">
              <q-icon name="error" color="negative" size="3em" class="q-mb-md" />
              <p>Unable to load profile information.</p>
              <q-btn color="primary" label="Try Again" @click="refetch" />
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Edit Profile Dialog -->
    <q-dialog v-model="showEditDialog" persistent>
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Edit Profile</div>
        </q-card-section>

        <q-card-section>
          <q-input v-model="editForm.display_name" label="Display Name" filled class="q-mb-md" />

          <q-select
            v-model="editForm.unit_preference"
            :options="[
              { label: 'Imperial (inches)', value: 'imperial' },
              { label: 'Metric (cm)', value: 'metric' },
            ]"
            label="Unit Preference"
            emit-value
            map-options
            filled
            class="q-mb-md"
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="primary" @click="showEditDialog = false" />
          <q-btn unelevated label="Save" color="primary" @click="saveProfile" :loading="saving" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Change Password Dialog -->
    <q-dialog v-model="showPasswordDialog" persistent>
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Change Password</div>
        </q-card-section>

        <q-card-section>
          <q-input
            v-model="passwordForm.currentPassword"
            label="Current Password"
            type="password"
            filled
            class="q-mb-md"
          />
          <q-input
            v-model="passwordForm.newPassword"
            label="New Password"
            type="password"
            filled
            class="q-mb-md"
          />
          <q-input
            v-model="passwordForm.confirmPassword"
            label="Confirm New Password"
            type="password"
            filled
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="primary" @click="showPasswordDialog = false" />
          <q-btn
            unelevated
            label="Change Password"
            color="primary"
            @click="changePassword"
            :loading="changingPassword"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useUserData } from '@nhost/vue'
import { nhost } from 'boot/nhost'
import { useQuasar } from 'quasar'
import { useProfileStore } from 'src/stores/profile'

const $q = useQuasar()
const user = useUserData()

// Profile store
const profileStore = useProfileStore()
const { profile, loading, refetch, updateProfile } = profileStore

// Reactive data
const saving = ref(false)
const changingPassword = ref(false)
const showEditDialog = ref(false)
const showPasswordDialog = ref(false)

const editForm = ref({
  display_name: '',
  unit_preference: 'imperial',
})

const passwordForm = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
})

// Methods
function formatDate(dateString) {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

onMounted(() => {
  if (profile.value) {
    editForm.value.display_name = profile.value.display_name || ''
    editForm.value.unit_preference = profile.value.unit_preference || 'imperial'
  }
})

async function saveProfile() {
  if (!editForm.value.display_name.trim()) {
    $q.notify({ type: 'warning', message: 'Display name cannot be empty' })
    return
  }

  saving.value = true
  try {
    await updateProfile({
      display_name: editForm.value.display_name.trim(),
      unit_preference: editForm.value.unit_preference === 'metric' ? 'metric' : 'imperial',
    })

    $q.notify({ type: 'positive', message: 'Profile updated successfully' })
    showEditDialog.value = false
  } catch (error) {
    console.error('Error updating profile:', error)
    $q.notify({
      type: 'negative',
      message: error.message || 'Failed to update profile',
    })
  } finally {
    saving.value = false
  }
}

async function changePassword() {
  if (!passwordForm.value.currentPassword || !passwordForm.value.newPassword) {
    $q.notify({ type: 'warning', message: 'Please fill in all password fields' })
    return
  }

  if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
    $q.notify({ type: 'warning', message: 'New passwords do not match' })
    return
  }

  if (passwordForm.value.newPassword.length < 6) {
    $q.notify({ type: 'warning', message: 'Password must be at least 6 characters long' })
    return
  }

  changingPassword.value = true
  try {
    const { error } = await nhost.auth.changePassword({
      newPassword: passwordForm.value.newPassword,
    })
    if (error) throw error

    $q.notify({ type: 'positive', message: 'Password changed successfully' })
    showPasswordDialog.value = false
    passwordForm.value = { currentPassword: '', newPassword: '', confirmPassword: '' }
  } catch (error) {
    console.error('Error changing password:', error)
    $q.notify({
      type: 'negative',
      message: error.message || 'Failed to change password',
    })
  } finally {
    changingPassword.value = false
  }
}

watch(profile, (val) => {
  console.log('[Profile Store] profile →', val)
})
</script>
