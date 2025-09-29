<!--
  AddGlazeDialog Component

  A popup dialog that allows users to add new glazes on the fly.
  Only the glaze name is required - all other fields are optional.

  Usage:
  <AddGlazeDialog
    v-model="showDialog"
    @glaze-added="onNewGlazeAdded"
  />

  Events:
  - glaze-added: Emitted when a new glaze is successfully created
    Payload: { id, name, brand, code, color, finish, series, cone, notes }
-->
<template>
  <q-dialog v-model="showDialog" persistent>
    <q-card style="min-width: 400px; max-width: 500px">
      <q-card-section>
        <div class="text-h6">Add New Glaze</div>
        <div class="text-subtitle2 text-grey-6">Fill in the glaze details below</div>
      </q-card-section>

      <q-card-section class="q-pt-none">
        <q-form @submit="onSubmit" class="q-gutter-md">
          <!-- Required: Glaze Name -->
          <q-input
            v-model="form.name"
            label="Glaze Name *"
            outlined
            :rules="[(val) => !!val || 'Glaze name is required']"
            lazy-rules
          />

          <!-- Optional fields -->
          <q-input v-model="form.code" label="Code" outlined hint="Glaze code or number" />

          <q-input v-model="form.color" label="Color" outlined hint="Glaze color description" />

          <q-input
            v-model="form.finish"
            label="Finish"
            outlined
            hint="e.g., Matte, Glossy, Satin"
          />

          <q-input
            v-model="form.series"
            label="Series"
            outlined
            hint="Glaze series or collection"
          />

          <q-input v-model="form.brand" label="Brand" outlined hint="Manufacturer or brand name" />

          <q-input v-model="form.cone" label="Cone" outlined hint="Firing temperature cone" />

          <q-input
            v-model="form.notes"
            label="Notes"
            outlined
            type="textarea"
            rows="2"
            hint="Additional notes about this glaze"
          />
        </q-form>
      </q-card-section>

      <q-card-actions align="right" class="q-pa-md">
        <q-btn flat label="Cancel" color="grey" @click="onCancel" />
        <q-btn
          flat
          label="Add Glaze"
          color="primary"
          @click="onSubmit"
          :loading="isLoading"
          :disable="!form.name"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script setup>
import { ref, reactive, watch } from 'vue'
import { useGlazesStore } from 'src/stores/glazes'
import { Notify } from 'quasar'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
})

const emit = defineEmits(['update:modelValue', 'glaze-added'])

const glazesStore = useGlazesStore()

const showDialog = ref(false)
const isLoading = ref(false)

const form = reactive({
  name: '',
  code: '',
  color: '',
  finish: '',
  series: '',
  brand: '',
  cone: '',
  notes: '',
})

// Watch for dialog open/close
watch(
  () => props.modelValue,
  (newVal) => {
    showDialog.value = newVal
    if (newVal) {
      resetForm()
    }
  },
)

watch(showDialog, (newVal) => {
  emit('update:modelValue', newVal)
})

function resetForm() {
  form.name = ''
  form.code = ''
  form.color = ''
  form.finish = ''
  form.series = ''
  form.brand = ''
  form.cone = ''
  form.notes = ''
}

async function onSubmit() {
  if (!form.name.trim()) {
    Notify.create({
      message: 'Glaze name is required',
      type: 'negative',
      position: 'top',
    })
    return
  }

  isLoading.value = true

  try {
    // Create the glaze object with only non-empty values
    const glazeData = {
      name: form.name.trim(),
      ...(form.code.trim() && { code: form.code.trim() }),
      ...(form.color.trim() && { color: form.color.trim() }),
      ...(form.finish.trim() && { finish: form.finish.trim() }),
      ...(form.series.trim() && { series: form.series.trim() }),
      ...(form.brand.trim() && { brand: form.brand.trim() }),
      ...(form.cone.trim() && { cone: form.cone.trim() }),
      ...(form.notes.trim() && { notes: form.notes.trim() }),
    }

    const newGlaze = await glazesStore.createGlaze(glazeData)

    if (newGlaze) {
      // Refresh the glaze list
      await glazesStore.refetch()

      Notify.create({
        message: `Glaze "${newGlaze.name}" added successfully!`,
        type: 'positive',
        position: 'top',
      })

      // Emit the new glaze to parent component
      emit('glaze-added', newGlaze)

      // Close dialog
      showDialog.value = false
    }
  } catch (error) {
    console.error('Failed to create glaze:', error)
    Notify.create({
      message: 'Failed to add glaze. Please try again.',
      type: 'negative',
      position: 'top',
    })
  } finally {
    isLoading.value = false
  }
}

function onCancel() {
  showDialog.value = false
}
</script>
