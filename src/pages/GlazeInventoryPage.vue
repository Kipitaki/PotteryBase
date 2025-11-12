<template>
  <q-page padding class="glaze-inventory-page">
    <div class="text-h5 text-weight-bold q-mb-xs">Glaze Inventory</div>
    <div class="text-body2 text-grey-7 q-mb-lg">
      Track the glazes you own and see what’s available in the shared class stash.
    </div>

    <div class="row q-col-gutter-xl">
      <div class="col-12 col-lg-6">
        <q-card flat bordered>
          <q-card-section class="row items-center justify-between">
            <div class="text-subtitle1 text-weight-medium">My Glazes</div>
            <div class="row items-center q-gutter-sm">
              <q-badge v-if="myGlazes.length" outline color="primary" align="top">
                {{ myGlazes.length }}
              </q-badge>
              <q-btn
                color="primary"
                icon="edit"
                label="Manage"
                dense
                outline
                :loading="managePreparing"
                :disable="managePreparing"
                @click="openManageDialog"
              />
            </div>
          </q-card-section>

          <q-separator />

          <q-card-section>
            <template v-if="!isAuthed">
              <div class="text-grey-6">Sign in to manage your personal glaze inventory.</div>
            </template>
          </q-card-section>

          <q-separator />

          <q-card-section>
            <template v-if="isLoading && !myGlazes.length">
              <div class="text-grey-6">Loading inventory…</div>
            </template>
            <template v-else-if="!myGlazes.length">
              <div class="text-grey-6">You haven’t logged any glazes yet.</div>
            </template>

            <q-list bordered separator class="q-mt-sm">
              <transition-group name="fade" tag="div">
                <q-item
                  v-for="entry in myGlazes"
                  :key="entry.id"
                  clickable
                  @click="openEdit(entry)"
                >
                  <q-item-section>
                    <div class="text-subtitle2 text-weight-medium">
                      {{ glazeDisplay(entry.glaze) }}
                    </div>
                    <div class="text-caption text-grey-7 q-mt-xs">
                      <span v-if="entry.quantity">
                        Qty: {{ entry.quantity }} {{ entry.unit || '' }} •
                      </span>
                      <span> Status: {{ entry.status || 'available' }} </span>
                    </div>
                    <div v-if="entry.location" class="text-caption text-grey-7">
                      Location: {{ entry.location }}
                    </div>
                    <div v-if="entry.notes" class="text-caption text-grey-6">
                      {{ entry.notes }}
                    </div>
                    <div class="text-caption text-grey-5 q-mt-xs">
                      Updated {{ formatRelative(entry.updated_at) }}
                    </div>

                    <div v-if="getMyPiecesForGlaze(entry).length" class="text-caption q-mt-sm">
                      <span class="text-grey-7">Used on:</span>
                      <q-btn
                        v-for="pieceGlaze in getMyPiecesForGlaze(entry)"
                        :key="pieceGlaze.piece.id"
                        flat
                        dense
                        color="primary"
                        size="sm"
                        class="q-ml-xs q-mt-xs"
                        :label="pieceGlaze.piece.title || 'Untitled'"
                        :to="{ name: 'viewpiece', query: { id: pieceGlaze.piece.id } }"
                      />
                    </div>
                  </q-item-section>
                  <q-item-section side top>
                    <q-btn
                      flat
                      dense
                      round
                      icon="delete"
                      color="negative"
                      @click.stop="removeGlaze(entry.id)"
                    />
                  </q-item-section>
                </q-item>
              </transition-group>
            </q-list>
          </q-card-section>
        </q-card>
      </div>

      <div class="col-12 col-lg-6">
        <q-card flat bordered>
          <q-card-section class="row items-center justify-between">
            <div class="text-subtitle1 text-weight-medium">Class Glazes</div>
            <q-badge v-if="classGlazes.length" outline color="primary" align="top">
              {{ classGlazes.length }}
            </q-badge>
          </q-card-section>

          <q-separator />

          <q-card-section>
            <template v-if="isLoading && !classGlazes.length">
              <div class="text-grey-6">Loading class inventory…</div>
            </template>
            <template v-else-if="!classGlazes.length">
              <div class="text-grey-6">No shared class glazes have been logged yet.</div>
            </template>

            <q-list bordered separator class="q-mt-sm">
              <q-item v-for="entry in classGlazes" :key="entry.id">
                <q-item-section>
                  <div class="text-subtitle2 text-weight-medium">
                    {{ glazeDisplay(entry.glaze) }}
                  </div>
                  <div class="text-caption text-grey-7 q-mt-xs">
                    <span v-if="entry.quantity">
                      Qty: {{ entry.quantity }} {{ entry.unit || '' }} •
                    </span>
                    <span>Status: {{ entry.status || 'available' }}</span>
                  </div>
                  <div v-if="entry.location" class="text-caption text-grey-7">
                    Location: {{ entry.location }}
                  </div>
                  <div v-if="entry.notes" class="text-caption text-grey-6">
                    {{ entry.notes }}
                  </div>
                  <div class="text-caption text-grey-5 q-mt-xs">
                    Updated {{ formatRelative(entry.updated_at) }}
                  </div>
                </q-item-section>
              </q-item>
            </q-list>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>

  <q-dialog v-model="manageDialog" persistent>
    <q-card style="min-width: 360px; max-width: 640px">
      <q-card-section>
        <div class="text-h6">Select My Glazes</div>
        <div class="text-caption text-grey-7 q-mt-xs">
          Choose glazes from the master list and move them to your personal inventory.
        </div>
      </q-card-section>

      <q-card-section class="row q-col-gutter-lg manage-transfer">
        <div class="col-12 col-md-6">
          <div class="text-subtitle2 text-weight-medium">All Glazes</div>
          <q-input
            v-model="manageSearchAvailable"
            dense
            outlined
            clearable
            placeholder="Search glazes"
            class="q-mt-sm q-mb-sm"
            :disable="manageSaving"
          />
          <q-list bordered separator class="transfer-list">
            <template v-if="filteredAvailable.length">
              <q-item
                v-for="option in filteredAvailable"
                :key="option.value"
                clickable
                @click="addToSelection(option.value)"
              >
                <q-item-section>
                  <div class="text-body2">{{ option.label }}</div>
                </q-item-section>
                <q-item-section side>
                  <q-btn
                    flat
                    dense
                    round
                    icon="chevron_right"
                    color="primary"
                    @click.stop="addToSelection(option.value)"
                  />
                </q-item-section>
              </q-item>
            </template>
            <div v-else class="text-grey-6 text-caption q-pa-md">No more glazes to add.</div>
          </q-list>
        </div>

        <div class="col-12 col-md-6">
          <div class="text-subtitle2 text-weight-medium">My Glazes</div>
          <q-input
            v-model="manageSearchSelected"
            dense
            outlined
            clearable
            placeholder="Search selected"
            class="q-mt-sm q-mb-sm"
            :disable="manageSaving"
          />
          <q-list bordered separator class="transfer-list">
            <template v-if="filteredSelected.length">
              <q-item
                v-for="option in filteredSelected"
                :key="option.value"
                clickable
                @click="removeFromSelection(option.value)"
              >
                <q-item-section>
                  <div class="text-body2">{{ option.label }}</div>
                </q-item-section>
                <q-item-section side>
                  <q-btn
                    flat
                    dense
                    round
                    icon="close"
                    color="negative"
                    @click.stop="removeFromSelection(option.value)"
                  />
                </q-item-section>
              </q-item>
            </template>
            <div v-else class="text-grey-6 text-caption q-pa-md">No glazes selected yet.</div>
          </q-list>
        </div>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn flat label="Cancel" :disable="manageSaving" v-close-popup />
        <q-btn
          color="primary"
          label="Save Selection"
          :loading="manageSaving"
          @click="applySelection"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>

  <q-dialog v-model="editDialog" persistent>
    <q-card style="min-width: 360px; max-width: 520px">
      <q-card-section>
        <div class="text-h6">Update Glaze Details</div>
        <div class="text-subtitle2 text-weight-medium q-mt-xs">
          {{ editingGlazeName }}
        </div>
      </q-card-section>

      <q-card-section class="q-gutter-md">
        <q-input
          v-model="form.quantity"
          label="Quantity"
          dense
          outlined
          type="number"
          inputmode="decimal"
        />
        <q-input v-model="form.unit" label="Unit (oz, jar, etc.)" dense outlined />
        <q-select v-model="form.status" :options="statusOptions" label="Status" dense outlined />
        <q-input v-model="form.location" label="Location" dense outlined />
        <q-input
          v-model="form.notes"
          type="textarea"
          label="Notes"
          dense
          outlined
          autogrow
          rows="2"
        />
      </q-card-section>

      <q-card-actions align="right">
        <q-btn flat label="Cancel" v-close-popup :disable="saving" />
        <q-btn color="negative" flat label="Remove" :disable="saving" @click="removeCurrentGlaze" />
        <q-btn color="primary" label="Save" :loading="saving" @click="saveGlaze" />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { date } from 'quasar'
import { useGlazesStore } from 'src/stores/glazes'
import { useGlazeInventoryStore } from 'src/stores/glazeInventory'

const glazesStore = useGlazesStore()
const inventoryStore = useGlazeInventoryStore()

const statusOptions = ['available', 'low', 'out', 'restock']

const form = reactive({
  glazeId: null,
  quantity: '',
  unit: '',
  location: '',
  status: 'available',
  notes: '',
})

const saving = ref(false)
const manageSaving = ref(false)
const managePreparing = ref(false)
const manageDialog = ref(false)
const editDialog = ref(false)
const editingEntry = ref(null)
const selectedGlazeIds = ref([])
const manageSearchAvailable = ref('')
const manageSearchSelected = ref('')

const profileId = inventoryStore.profileId
const isAuthed = computed(() => Boolean(profileId.value))
const myGlazes = computed(() => inventoryStore.myGlazes.value || [])
const classGlazes = computed(() => inventoryStore.classGlazes.value || [])
const isLoading = computed(() => Boolean(inventoryStore.isLoading.value))

const allGlazeOptions = computed(() =>
  (glazesStore.options.value || []).map((opt) => ({
    value: String(opt.id),
    label: opt.label,
  })),
)

const optionsMap = computed(() => {
  const map = new Map()
  allGlazeOptions.value.forEach((opt) => {
    map.set(opt.value, opt.label)
  })
  return map
})

const availableOptions = computed(() =>
  allGlazeOptions.value.filter((opt) => !selectedGlazeIds.value.includes(opt.value)),
)

const selectedOptions = computed(() =>
  selectedGlazeIds.value.map((value) => ({
    value,
    label: optionsMap.value.get(value) || value,
  })),
)

const filteredAvailable = computed(() => {
  const search = manageSearchAvailable.value.trim().toLowerCase()
  if (!search) return availableOptions.value
  return availableOptions.value.filter((opt) => opt.label.toLowerCase().includes(search))
})

const filteredSelected = computed(() => {
  const search = manageSearchSelected.value.trim().toLowerCase()
  if (!search) return selectedOptions.value
  return selectedOptions.value.filter((opt) => opt.label.toLowerCase().includes(search))
})

const editingGlazeName = computed(() => {
  if (!editingEntry.value) return ''
  return glazeDisplay(editingEntry.value.glaze)
})

onMounted(() => {
  glazesStore.refetch()
})

function glazeDisplay(glaze) {
  if (glaze.display_name) return glaze.display_name
  const parts = [glaze.name, glaze.brand, glaze.color, glaze.cone ? `Cone ${glaze.cone}` : null]
  return parts.filter(Boolean).join(' • ')
}

function getMyPiecesForGlaze(entry) {
  if (!entry?.glaze?.piece_glazes || !profileId.value) {
    return []
  }
  return entry.glaze.piece_glazes.filter((pg) => pg.piece?.owner_id === profileId.value)
}

function formatRelative(value) {
  if (!value) return ''
  return date.formatDate(value, 'MMM D, YYYY h:mm A')
}

function resetForm() {
  form.glazeId = null
  form.quantity = ''
  form.unit = ''
  form.location = ''
  form.status = 'available'
  form.notes = ''
}

async function openManageDialog() {
  if (!isAuthed.value) {
    return
  }
  managePreparing.value = true
  try {
    const options = glazesStore.options.value || []
    if (!options.length) {
      try {
        await glazesStore.refetch()
      } catch (error) {
        console.error('Failed to load glazes', error)
      }
    }
    selectedGlazeIds.value = myGlazes.value.map((entry) => String(entry.glaze.id))
    manageDialog.value = true
  } finally {
    managePreparing.value = false
  }
}

function addToSelection(value) {
  if (!selectedGlazeIds.value.includes(value)) {
    selectedGlazeIds.value = [...selectedGlazeIds.value, value]
  }
}

function removeFromSelection(value) {
  selectedGlazeIds.value = selectedGlazeIds.value.filter((id) => id !== value)
}

async function applySelection() {
  if (!isAuthed.value) return
  manageSaving.value = true
  try {
    const originalMap = new Map(myGlazes.value.map((entry) => [String(entry.glaze.id), entry]))
    const selectedSet = new Set(selectedGlazeIds.value)
    const operations = []

    selectedSet.forEach((id) => {
      if (!originalMap.has(id)) {
        operations.push(
          inventoryStore
            .upsertMyGlaze({
              glaze_id: Number(id),
              quantity: null,
              unit: null,
              location: null,
              status: 'available',
              notes: null,
            })
            .catch((err) => {
              console.error('Error adding glaze:', err)
              throw err
            }),
        )
      }
    })

    originalMap.forEach((entry, id) => {
      if (!selectedSet.has(id)) {
        operations.push(
          inventoryStore.removeMyGlaze(entry.id).catch((err) => {
            console.error('Error removing glaze:', err)
            throw err
          }),
        )
      }
    })

    if (operations.length) {
      await Promise.all(operations)
    }
    manageDialog.value = false
  } catch (error) {
    console.error('Error applying selection:', error)
    // You could add a Quasar notification here to show the error to the user
  } finally {
    manageSaving.value = false
  }
}

function openEdit(entry) {
  editingEntry.value = entry
  form.glazeId = entry.glaze.id
  form.quantity = entry.quantity ?? ''
  form.unit = entry.unit ?? ''
  form.location = entry.location ?? ''
  form.status = entry.status ?? 'available'
  form.notes = entry.notes ?? ''
  editDialog.value = true
}

async function saveGlaze() {
  if (!form.glazeId) return
  try {
    saving.value = true
    await inventoryStore.upsertMyGlaze({
      glaze_id: form.glazeId,
      quantity: form.quantity ? Number(form.quantity) : null,
      unit: form.unit || null,
      location: form.location || null,
      status: form.status || null,
      notes: form.notes || null,
    })
    editDialog.value = false
  } finally {
    saving.value = false
  }
}

async function removeGlaze(id) {
  await inventoryStore.removeMyGlaze(id)
  if (form.glazeId) {
    const stillExists = myGlazes.value.some((entry) => entry.glaze.id === form.glazeId)
    if (!stillExists) {
      resetForm()
    }
  }
}

async function removeCurrentGlaze() {
  if (!editingEntry.value) return
  await removeGlaze(editingEntry.value.id)
  editDialog.value = false
}
</script>

<style scoped>
.glaze-inventory-page {
  max-width: 1200px;
  margin: 0 auto;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.manage-transfer .transfer-list {
  max-height: 320px;
  overflow-y: auto;
  border-radius: 8px;
}
</style>
