<template>
  <q-page padding class="bg-grey-1 bandanas-page">
    <div class="row items-center q-mb-md">
      <q-btn
        flat
        icon="arrow_back"
        label="Back to Buyers"
        @click="router.push({ name: 'bandanas-buyers' })"
      />
    </div>

    <q-card>
      <q-card-section>
        <div class="text-h6">
          {{ isNew ? 'Add Buyer' : 'Edit Buyer' }}
        </div>
      </q-card-section>

      <q-card-section>
        <div class="row q-col-gutter-md">
          <div class="col-12 col-md-6">
            <q-input
              v-model="form.first_name"
              label="First Name *"
              outlined
              :error="!form.first_name"
              error-message="First name is required"
            />
          </div>
          <div class="col-12 col-md-6">
            <q-input
              v-model="form.last_name"
              label="Last Name *"
              outlined
              :error="!form.last_name"
              error-message="Last name is required"
            />
          </div>
          <div class="col-12">
            <q-input
              v-model="form.email"
              label="Email"
              type="email"
              outlined
            />
          </div>
        </div>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn
          flat
          label="Cancel"
          @click="router.push({ name: 'bandanas-buyers' })"
        />
        <q-btn
          color="purple"
          label="Save"
          :loading="saving"
          @click="handleSave"
        />
      </q-card-actions>
    </q-card>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useBuyersStore } from 'src/stores/bandanas/buyers'
import { useQuasar } from 'quasar'

const router = useRouter()
const route = useRoute()
const $q = useQuasar()
const buyersStore = useBuyersStore()

const isNew = ref(true)
const saving = ref(false)

const form = ref({
  first_name: '',
  last_name: '',
  email: '',
})

onMounted(async () => {
  const id = route.params.id
  if (id && id !== 'new') {
    isNew.value = false
    // Fetch buyer data
    const buyer = buyersStore.buyers.value.find((b) => b.id === id)
    if (buyer) {
      form.value = {
        first_name: buyer.first_name || '',
        last_name: buyer.last_name || '',
        email: buyer.email || '',
      }
    } else {
      // If not found, wait for store to load and try again
      await buyersStore.refetch()
      const buyerAfterRefetch = buyersStore.buyers.value.find((b) => b.id === id)
      if (buyerAfterRefetch) {
        form.value = {
          first_name: buyerAfterRefetch.first_name || '',
          last_name: buyerAfterRefetch.last_name || '',
          email: buyerAfterRefetch.email || '',
        }
      }
    }
  }
})

async function handleSave() {
  if (!form.value.first_name || !form.value.last_name) {
    $q.notify({
      type: 'negative',
      message: 'First name and last name are required',
    })
    return
  }

  saving.value = true
  try {
    if (isNew.value) {
      await buyersStore.createBuyer({
        first_name: form.value.first_name,
        last_name: form.value.last_name,
        email: form.value.email || null,
      })
      $q.notify({
        type: 'positive',
        message: 'Buyer created successfully',
      })
    } else {
      await buyersStore.updateBuyer(route.params.id, {
        first_name: form.value.first_name,
        last_name: form.value.last_name,
        email: form.value.email || null,
      })
      $q.notify({
        type: 'positive',
        message: 'Buyer updated successfully',
      })
    }
    router.push({ name: 'bandanas-buyers' })
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Error saving buyer: ' + error.message,
    })
  } finally {
    saving.value = false
  }
}
</script>

