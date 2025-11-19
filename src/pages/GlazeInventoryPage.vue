<template>
  <q-page padding class="glaze-inventory-page">
    <div class="row items-center justify-between q-mb-xs">
      <div class="text-h5 text-weight-bold">Glaze Inventory</div>
      <q-btn
        flat
        icon="list"
        label="View All Glazes"
        color="primary"
        @click="$router.push('/glazes/all')"
      />
    </div>
    <div class="text-body2 text-grey-7 q-mb-lg">
      Track the glazes you own and see what's available in the shared class stash.
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
                icon="upload"
                label="Import CSV"
                dense
                outline
                :loading="csvImporting"
                :disable="csvImporting || !isAuthed"
                @click="csvDialog = true"
              />
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

  <!-- CSV/JSON Import Dialog -->
  <q-dialog v-model="csvDialog" persistent>
    <q-card style="min-width: 600px; max-width: 900px">
      <q-card-section>
        <div class="text-h6">Import Glazes</div>
        <div class="text-caption text-grey-7 q-mt-sm">
          Upload a file or paste CSV/JSON data. Must include a <code>code</code> column/field that
          matches glaze codes. Optional: <code>quantity</code>, <code>unit</code>,
          <code>location</code>, <code>status</code>, <code>notes</code>.
        </div>
      </q-card-section>

      <q-card-section>
        <q-tabs v-model="importTab" class="text-grey" active-color="primary">
          <q-tab name="file" label="Upload File" icon="attach_file" />
          <q-tab name="csv" label="Paste CSV" icon="content_paste" />
          <q-tab name="json" label="Paste JSON" icon="code" />
        </q-tabs>

        <q-separator />

        <q-tab-panels v-model="importTab" animated>
          <q-tab-panel name="file">
            <q-file
              v-model="csvFile"
              label="Choose CSV or JSON file"
              accept=".csv,.json,text/csv,application/json"
              outlined
              :disable="csvImporting"
              @update:model-value="handleFileUpload"
            >
              <template v-slot:prepend>
                <q-icon name="attach_file" />
              </template>
            </q-file>
          </q-tab-panel>

          <q-tab-panel name="csv">
            <div class="text-subtitle2 q-mb-sm">Paste CSV data:</div>
            <q-input
              v-model="pastedData"
              type="textarea"
              outlined
              rows="10"
              placeholder="code,quantity,unit,location,status,notes&#10;AM-123,2,lb,Shelf A,available,My favorite glaze&#10;PC-456,1,oz,Drawer 2,low,Need to reorder"
              :disable="csvImporting"
              @update:model-value="parsePastedData"
            />
          </q-tab-panel>

          <q-tab-panel name="json">
            <div class="text-subtitle2 q-mb-sm">Paste JSON data:</div>
            <q-input
              v-model="pastedData"
              type="textarea"
              outlined
              rows="10"
              placeholder='[&#10;  {"code": "AM-123", "quantity": 2, "unit": "lb", "location": "Shelf A", "status": "available", "notes": "My favorite glaze"},&#10;  {"code": "PC-456", "quantity": 1, "unit": "oz", "location": "Drawer 2", "status": "low", "notes": "Need to reorder"}&#10;]'
              :disable="csvImporting"
              @update:model-value="parsePastedData"
            />
          </q-tab-panel>
        </q-tab-panels>

        <div v-if="csvPreview.length" class="q-mt-md">
          <div class="text-subtitle2 q-mb-sm">Preview ({{ csvPreview.length }} rows)</div>
          <q-table
            :rows="csvPreview.slice(0, 5)"
            :columns="csvColumns"
            row-key="__index"
            flat
            dense
            :rows-per-page-options="[0]"
          >
            <template v-slot:body-cell-code="props">
              <q-td :props="props">
                <div class="row items-center q-gutter-xs">
                  <span>{{ props.value }}</span>
                  <q-icon
                    v-if="glazeCodeMap && glazeCodeMap.has(props.value)"
                    name="check_circle"
                    color="positive"
                    size="sm"
                  />
                  <q-icon
                    v-else-if="glazeCodeMap"
                    name="error"
                    color="negative"
                    size="sm"
                    :title="`Glaze with code '${props.value}' not found`"
                  />
                </div>
              </q-td>
            </template>
          </q-table>
          <div v-if="csvPreview.length > 5" class="text-caption text-grey-7 q-mt-xs">
            ... and {{ csvPreview.length - 5 }} more rows
          </div>
        </div>

        <div v-if="csvImportResults" class="q-mt-md">
          <q-banner :class="csvImportResults.failed > 0 ? 'bg-warning' : 'bg-positive'" rounded>
            <template v-slot:avatar>
              <q-icon
                :name="csvImportResults.failed > 0 ? 'warning' : 'check_circle'"
                color="white"
              />
            </template>
            <div class="text-white">
              <div class="text-weight-bold">
                Import complete: {{ csvImportResults.success }} succeeded,
                {{ csvImportResults.failed }} failed
              </div>
              <div v-if="csvImportResults.errors.length" class="q-mt-sm">
                <div
                  v-for="(err, idx) in csvImportResults.errors.slice(0, 5)"
                  :key="idx"
                  class="text-caption"
                >
                  Code "{{ err.code }}": {{ err.error }}
                </div>
                <div v-if="csvImportResults.errors.length > 5" class="text-caption">
                  ... and {{ csvImportResults.errors.length - 5 }} more errors
                </div>
              </div>
            </div>
          </q-banner>
        </div>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn
          flat
          label="View All Glazes"
          icon="list"
          :disable="csvImporting"
          @click="viewGlazesDialog = true"
        />
        <q-btn flat label="Cancel" :disable="csvImporting" @click="closeCsvDialog" />
        <q-btn
          color="primary"
          label="Import"
          :loading="csvImporting"
          :disable="!csvPreview.length || csvImporting"
          @click="importCSV"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>

  <!-- View All Glazes Dialog -->
  <q-dialog v-model="viewGlazesDialog">
    <q-card style="min-width: 700px; max-width: 1000px">
      <q-card-section>
        <div class="text-h6">All Glazes in Database</div>
        <div class="text-caption text-grey-7 q-mt-sm">
          Search by code, name, brand, or color to find glazes for your CSV import.
        </div>
      </q-card-section>

      <q-card-section>
        <q-input
          v-model="glazeSearch"
          outlined
          placeholder="Search glazes by code, name, brand, or color..."
          clearable
        >
          <template v-slot:prepend>
            <q-icon name="search" />
          </template>
        </q-input>
      </q-card-section>

      <q-card-section class="q-pt-none">
        <q-table
          :rows="filteredGlazes || []"
          :columns="glazeTableColumns"
          row-key="id"
          flat
          dense
          :rows-per-page-options="[10, 25, 50, 100]"
          :pagination="{ rowsPerPage: 25 }"
        >
          <template v-slot:body-cell-code="props">
            <q-td :props="props">
              <div class="text-weight-medium">{{ props.value || '(no code)' }}</div>
            </q-td>
          </template>
          <template v-slot:body-cell-name="props">
            <q-td :props="props">
              <div>{{ props.value || '-' }}</div>
              <div class="text-caption text-grey-7">
                {{ props.row.brand ? props.row.brand : '' }}
                <span v-if="props.row.brand && props.row.color"> • </span>
                {{ props.row.color || '' }}
              </div>
            </q-td>
          </template>
        </q-table>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn flat label="Close" color="primary" @click="viewGlazesDialog = false" />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
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

// CSV/JSON Import
const csvDialog = ref(false)
const importTab = ref('file')
const csvFile = ref(null)
const pastedData = ref('')
const csvPreview = ref([])
const csvImporting = ref(false)
const csvImportResults = ref(null)
const csvColumns = [
  { name: 'code', label: 'Code', field: 'code', align: 'left' },
  { name: 'quantity', label: 'Quantity', field: 'quantity', align: 'left' },
  { name: 'unit', label: 'Unit', field: 'unit', align: 'left' },
  { name: 'location', label: 'Location', field: 'location', align: 'left' },
  { name: 'status', label: 'Status', field: 'status', align: 'left' },
  { name: 'notes', label: 'Notes', field: 'notes', align: 'left' },
]

// View Glazes Dialog
const viewGlazesDialog = ref(false)
const glazeSearch = ref('')
const glazeTableColumns = [
  { name: 'code', label: 'Code', field: 'code', align: 'left', sortable: true },
  { name: 'name', label: 'Name', field: 'name', align: 'left', sortable: true },
  { name: 'cone', label: 'Cone', field: 'cone', align: 'center', sortable: true },
  { name: 'series', label: 'Series', field: 'series', align: 'left', sortable: true },
  { name: 'finish', label: 'Finish', field: 'finish', align: 'left', sortable: true },
]

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

// Create a map of glaze codes to glaze IDs for CSV matching
const glazeCodeMap = computed(() => {
  const map = new Map()
  // glazesStore.all is a computed ref, so we need to check if it exists and is an array
  const allGlazes = glazesStore.all?.value || []
  if (Array.isArray(allGlazes)) {
    allGlazes.forEach((glaze) => {
      if (glaze && glaze.code) {
        map.set(String(glaze.code).trim(), glaze.id)
      }
    })
  }
  return map
})

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

// Filtered glazes for the view dialog
const filteredGlazes = computed(() => {
  const allGlazes = glazesStore.all?.value || []
  if (!Array.isArray(allGlazes) || allGlazes.length === 0) {
    return []
  }

  // Create a copy of the array to avoid mutating the read-only reactive array
  const glazes = [...allGlazes]
  const search = glazeSearch.value.trim().toLowerCase()

  if (!search) {
    return glazes.sort((a, b) => {
      const codeA = (a.code || '').toLowerCase()
      const codeB = (b.code || '').toLowerCase()
      return codeA.localeCompare(codeB)
    })
  }

  return glazes
    .filter((glaze) => {
      const code = (glaze.code || '').toLowerCase()
      const name = (glaze.name || '').toLowerCase()
      const brand = (glaze.brand || '').toLowerCase()
      const color = (glaze.color || '').toLowerCase()
      const searchLower = search.toLowerCase()

      return (
        code.includes(searchLower) ||
        name.includes(searchLower) ||
        brand.includes(searchLower) ||
        color.includes(searchLower)
      )
    })
    .sort((a, b) => {
      const codeA = (a.code || '').toLowerCase()
      const codeB = (b.code || '').toLowerCase()
      return codeA.localeCompare(codeB)
    })
})

onMounted(() => {
  glazesStore.refetch()
})

// Ensure glazes are loaded when CSV dialog opens
watch(csvDialog, async (isOpen) => {
  if (isOpen) {
    const all = glazesStore.all?.value || []
    if (!all.length) {
      await glazesStore.refetch()
    }
  }
})

// Ensure glazes are loaded when view glazes dialog opens
watch(viewGlazesDialog, async (isOpen) => {
  if (isOpen) {
    const all = glazesStore.all?.value || []
    if (!all.length) {
      await glazesStore.refetch()
    }
  }
})

function glazeDisplay(glaze) {
  if (glaze.display_name) return glaze.display_name
  const parts = [glaze.name, glaze.brand, glaze.color, glaze.cone ? `Cone ${glaze.cone}` : null]
  return parts.filter(Boolean).join(' • ')
}

function getMyPiecesForGlaze(entry) {
  // Pieces are already filtered by owner_id on the server
  if (!entry?.glaze?.piece_glazes) {
    return []
  }
  return entry.glaze.piece_glazes
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

// CSV/JSON Import Functions
function parseCSVLine(line) {
  const result = []
  let current = ''
  let inQuotes = false

  for (let i = 0; i < line.length; i++) {
    const char = line[i]
    if (char === '"') {
      inQuotes = !inQuotes
    } else if (char === ',' && !inQuotes) {
      result.push(current.trim())
      current = ''
    } else {
      current += char
    }
  }
  result.push(current.trim())
  return result
}

function parseCSVText(text) {
  const lines = text.split('\n').filter((line) => line.trim())
  if (lines.length === 0) {
    return []
  }

  // Parse header
  const headers = parseCSVLine(lines[0]).map((h) => h.toLowerCase().trim())
  const codeIndex = headers.findIndex((h) => h === 'code')
  if (codeIndex === -1) {
    throw new Error('CSV must have a "code" column')
  }

  // Parse rows
  const rows = []
  for (let i = 1; i < lines.length; i++) {
    const values = parseCSVLine(lines[i])
    const row = { __index: i - 1 }
    headers.forEach((header, idx) => {
      row[header] = values[idx] || ''
    })
    rows.push(row)
  }

  return rows
}

function parseJSONText(text) {
  try {
    const data = JSON.parse(text)
    if (!Array.isArray(data)) {
      throw new Error('JSON must be an array of objects')
    }

    const rows = []
    data.forEach((item, index) => {
      if (typeof item !== 'object' || item === null) {
        throw new Error(`Row ${index + 1} is not an object`)
      }
      if (!item.code) {
        throw new Error(`Row ${index + 1} is missing "code" field`)
      }

      const row = { __index: index }
      // Normalize field names to lowercase
      Object.keys(item).forEach((key) => {
        row[key.toLowerCase()] = String(item[key] || '')
      })
      rows.push(row)
    })

    return rows
  } catch (error) {
    if (error instanceof SyntaxError) {
      throw new Error('Invalid JSON format: ' + error.message)
    }
    throw error
  }
}

async function handleFileUpload() {
  if (!csvFile.value) {
    csvPreview.value = []
    csvImportResults.value = null
    return
  }

  try {
    // Ensure glazes are loaded for validation
    const all = glazesStore.all?.value || []
    if (!all.length) {
      await glazesStore.refetch()
    }

    const text = await csvFile.value.text()
    const fileName = csvFile.value.name.toLowerCase()

    if (fileName.endsWith('.json')) {
      csvPreview.value = parseJSONText(text)
    } else {
      csvPreview.value = parseCSVText(text)
    }
    csvImportResults.value = null
  } catch (error) {
    console.error('File parsing error:', error)
    csvPreview.value = []
    csvImportResults.value = {
      success: 0,
      failed: 0,
      errors: [{ code: 'N/A', error: error.message || 'Failed to parse file' }],
    }
  }
}

async function parsePastedData() {
  if (!pastedData.value.trim()) {
    csvPreview.value = []
    csvImportResults.value = null
    return
  }

  try {
    // Ensure glazes are loaded for validation
    const all = glazesStore.all?.value || []
    if (!all.length) {
      await glazesStore.refetch()
    }

    if (importTab.value === 'json') {
      csvPreview.value = parseJSONText(pastedData.value)
    } else {
      csvPreview.value = parseCSVText(pastedData.value)
    }
    csvImportResults.value = null
  } catch (error) {
    console.error('Parsing error:', error)
    csvPreview.value = []
    csvImportResults.value = {
      success: 0,
      failed: 0,
      errors: [{ code: 'N/A', error: error.message || 'Failed to parse data' }],
    }
  }
}

async function importCSV() {
  if (!csvPreview.value.length || !isAuthed.value) return

  csvImporting.value = true
  csvImportResults.value = null

  try {
    // Ensure glazes are loaded
    const all = glazesStore.all?.value || []
    if (!all.length) {
      await glazesStore.refetch()
    }

    const results = await inventoryStore.bulkImportFromCSV(csvPreview.value, glazeCodeMap.value)
    csvImportResults.value = results

    if (results.success > 0) {
      // Refresh the inventory
      await inventoryStore.refetch()
    }
  } catch (error) {
    console.error('CSV import error:', error)
    csvImportResults.value = {
      success: 0,
      failed: csvPreview.value.length,
      errors: [{ code: 'N/A', error: error instanceof Error ? error.message : 'Import failed' }],
    }
  } finally {
    csvImporting.value = false
  }
}

function closeCsvDialog() {
  csvDialog.value = false
  csvFile.value = null
  pastedData.value = ''
  csvPreview.value = []
  csvImportResults.value = null
  importTab.value = 'file'
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
