<template>
  <q-page class="all-glazes-page q-pa-md">
    <div class="q-mb-md">
      <div class="row items-center q-mb-md">
        <div class="col">
          <div class="text-h4">All Glazes</div>
          <div class="text-caption text-grey-7 q-mt-xs">
            View and edit all glazes in the database. Click on any field to edit.
          </div>
        </div>
        <div class="col-auto">
          <div class="row items-center q-gutter-sm">
            <q-btn
              flat
              icon="upload"
              label="Import CSV"
              color="primary"
              @click="importDialog = true"
            />
            <q-btn
              flat
              icon="download"
              label="Download CSV"
              color="primary"
              @click="downloadCSV"
            />
            <q-btn
              flat
              icon="arrow_back"
              label="Back to Inventory"
              color="primary"
              @click="$router.push('/glazes')"
            />
          </div>
        </div>
      </div>

      <q-input
        v-model="search"
        outlined
        placeholder="Search glazes by code, name, brand, or color..."
        clearable
        class="q-mb-md"
      >
        <template v-slot:prepend>
          <q-icon name="search" />
        </template>
      </q-input>
    </div>

    <q-table
      :rows="filteredGlazes"
      :columns="columns"
      row-key="id"
      flat
      :rows-per-page-options="[25, 50, 100, 200]"
      :pagination="{ rowsPerPage: 50 }"
      :loading="isLoading"
    >
      <template v-slot:body-cell-code="props">
        <q-td :props="props">
          <q-input
            v-if="editingId === props.row.id && editingField === 'code'"
            v-model="editingValue"
            dense
            outlined
            autofocus
            @blur="saveEdit(props.row.id, 'code', editingValue)"
            @keyup.enter="saveEdit(props.row.id, 'code', editingValue)"
            @keyup.esc="cancelEdit"
          />
          <div
            v-else
            class="editable-field"
            @click="startEdit(props.row.id, 'code', props.value)"
          >
            <span class="text-weight-medium">{{ props.value || '(no code)' }}</span>
            <q-icon name="edit" size="xs" class="q-ml-xs text-grey-5" />
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-name="props">
        <q-td :props="props">
          <q-input
            v-if="editingId === props.row.id && editingField === 'name'"
            v-model="editingValue"
            dense
            outlined
            autofocus
            @blur="saveEdit(props.row.id, 'name', editingValue)"
            @keyup.enter="saveEdit(props.row.id, 'name', editingValue)"
            @keyup.esc="cancelEdit"
          />
          <div
            v-else
            class="editable-field"
            @click="startEdit(props.row.id, 'name', props.value)"
          >
            <span>{{ props.value || '-' }}</span>
            <q-icon name="edit" size="xs" class="q-ml-xs text-grey-5" />
          </div>
          <div class="text-caption text-grey-7">
            {{ props.row.brand ? props.row.brand : '' }}
            <span v-if="props.row.brand && props.row.color"> • </span>
            {{ props.row.color || '' }}
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-brand="props">
        <q-td :props="props">
          <q-input
            v-if="editingId === props.row.id && editingField === 'brand'"
            v-model="editingValue"
            dense
            outlined
            autofocus
            @blur="saveEdit(props.row.id, 'brand', editingValue)"
            @keyup.enter="saveEdit(props.row.id, 'brand', editingValue)"
            @keyup.esc="cancelEdit"
          />
          <div
            v-else
            class="editable-field"
            @click="startEdit(props.row.id, 'brand', props.value)"
          >
            <span>{{ props.value || '-' }}</span>
            <q-icon name="edit" size="xs" class="q-ml-xs text-grey-5" />
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-color="props">
        <q-td :props="props">
          <q-input
            v-if="editingId === props.row.id && editingField === 'color'"
            v-model="editingValue"
            dense
            outlined
            autofocus
            @blur="saveEdit(props.row.id, 'color', editingValue)"
            @keyup.enter="saveEdit(props.row.id, 'color', editingValue)"
            @keyup.esc="cancelEdit"
          />
          <div
            v-else
            class="editable-field"
            @click="startEdit(props.row.id, 'color', props.value)"
          >
            <span>{{ props.value || '-' }}</span>
            <q-icon name="edit" size="xs" class="q-ml-xs text-grey-5" />
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-cone="props">
        <q-td :props="props">
          <q-input
            v-if="editingId === props.row.id && editingField === 'cone'"
            v-model.number="editingValue"
            type="number"
            dense
            outlined
            autofocus
            @blur="saveEdit(props.row.id, 'cone', editingValue)"
            @keyup.enter="saveEdit(props.row.id, 'cone', editingValue)"
            @keyup.esc="cancelEdit"
          />
          <div
            v-else
            class="editable-field"
            @click="startEdit(props.row.id, 'cone', props.value)"
          >
            <span>{{ props.value || '-' }}</span>
            <q-icon name="edit" size="xs" class="q-ml-xs text-grey-5" />
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-series="props">
        <q-td :props="props">
          <q-input
            v-if="editingId === props.row.id && editingField === 'series'"
            v-model="editingValue"
            dense
            outlined
            autofocus
            @blur="saveEdit(props.row.id, 'series', editingValue)"
            @keyup.enter="saveEdit(props.row.id, 'series', editingValue)"
            @keyup.esc="cancelEdit"
          />
          <div
            v-else
            class="editable-field"
            @click="startEdit(props.row.id, 'series', props.value)"
          >
            <span>{{ props.value || '-' }}</span>
            <q-icon name="edit" size="xs" class="q-ml-xs text-grey-5" />
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-finish="props">
        <q-td :props="props">
          <q-input
            v-if="editingId === props.row.id && editingField === 'finish'"
            v-model="editingValue"
            dense
            outlined
            autofocus
            @blur="saveEdit(props.row.id, 'finish', editingValue)"
            @keyup.enter="saveEdit(props.row.id, 'finish', editingValue)"
            @keyup.esc="cancelEdit"
          />
          <div
            v-else
            class="editable-field"
            @click="startEdit(props.row.id, 'finish', props.value)"
          >
            <span>{{ props.value || '-' }}</span>
            <q-icon name="edit" size="xs" class="q-ml-xs text-grey-5" />
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-display_name="props">
        <q-td :props="props">
          <q-input
            v-if="editingId === props.row.id && editingField === 'display_name'"
            v-model="editingValue"
            dense
            outlined
            autofocus
            @blur="saveEdit(props.row.id, 'display_name', editingValue)"
            @keyup.enter="saveEdit(props.row.id, 'display_name', editingValue)"
            @keyup.esc="cancelEdit"
          />
          <div
            v-else
            class="editable-field"
            @click="startEdit(props.row.id, 'display_name', props.value)"
          >
            <span>{{ props.value || '-' }}</span>
            <q-icon name="edit" size="xs" class="q-ml-xs text-grey-5" />
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-notes="props">
        <q-td :props="props">
          <q-input
            v-if="editingId === props.row.id && editingField === 'notes'"
            v-model="editingValue"
            dense
            outlined
            autofocus
            @blur="saveEdit(props.row.id, 'notes', editingValue)"
            @keyup.enter="saveEdit(props.row.id, 'notes', editingValue)"
            @keyup.esc="cancelEdit"
          />
          <div
            v-else
            class="editable-field"
            @click="startEdit(props.row.id, 'notes', props.value)"
          >
            <span class="text-caption">{{ props.value || '-' }}</span>
            <q-icon name="edit" size="xs" class="q-ml-xs text-grey-5" />
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-pages="props">
        <q-td :props="props">
          <div
            v-if="props.value"
            class="editable-field"
            @click="openPagesDialog(props.row)"
          >
            <span class="text-caption">{{ props.value.substring(0, 50) }}{{ props.value.length > 50 ? '...' : '' }}</span>
            <q-icon name="edit" size="xs" class="q-ml-xs text-grey-5" />
          </div>
          <div
            v-else
            class="editable-field"
            @click="openPagesDialog(props.row)"
          >
            <span class="text-grey-6 text-caption">Click to add pages</span>
            <q-icon name="add" size="xs" class="q-ml-xs text-grey-5" />
          </div>
        </q-td>
      </template>
    </q-table>

    <!-- Pages Edit Dialog -->
    <q-dialog v-model="pagesDialog" persistent>
      <q-card style="min-width: 600px; max-width: 800px">
        <q-card-section>
          <div class="text-h6">Edit Pages</div>
          <div class="text-caption text-grey-7 q-mt-sm">
            {{ editingPagesGlaze ? `${editingPagesGlaze.code || ''} - ${editingPagesGlaze.name || ''}` : '' }}
          </div>
        </q-card-section>

        <q-card-section>
          <q-input
            v-model="pagesValue"
            type="textarea"
            outlined
            rows="15"
            placeholder="Enter pages content..."
            :disable="isLoading"
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancel" :disable="isLoading" @click="closePagesDialog" />
          <q-btn
            color="primary"
            label="Save"
            :loading="isLoading"
            :disable="isLoading"
            @click="savePages"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Import CSV Dialog -->
    <q-dialog v-model="importDialog" persistent>
      <q-card style="min-width: 700px; max-width: 900px">
        <q-card-section>
          <div class="text-h6">Import Glazes from CSV</div>
          <div class="text-caption text-grey-7 q-mt-sm">
            Upload a file or paste CSV data. Must include a <code>code</code> column. Optional
            fields: <code>name</code>, <code>brand</code>, <code>color</code>, <code>cone</code>,
            <code>series</code>, <code>finish</code>, <code>notes</code>, <code>pages</code>.
            <br />
            <span class="text-grey-6"
              >Note: <code>display_name</code> is computed automatically from <code>name</code> and
              <code>code</code>, so it will be ignored if present in your CSV.</span
            >
            <br />
            Glazes with matching codes will be updated, new codes will be created.
          </div>
        </q-card-section>

        <q-card-section>
          <q-tabs v-model="importTab" class="text-grey" active-color="primary">
            <q-tab name="file" label="Upload File" icon="attach_file" />
            <q-tab name="csv" label="Paste CSV" icon="content_paste" />
          </q-tabs>

          <q-separator />

          <q-tab-panels v-model="importTab" animated>
            <q-tab-panel name="file">
              <q-file
                v-model="csvFile"
                label="Choose CSV file"
                accept=".csv,text/csv"
                outlined
                :disable="importing"
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
                placeholder="code,name,brand,color,cone,series,finish,notes,pages&#10;AM-123,Cordovan,Mayco,Deep Red Brown,6,Stoneware,Gloss,My favorite glaze,Long text content here&#10;PC-456,Riptide,Mayco,Blue-Green,6,Stoneware,Gloss/Variegated,Need to reorder,More pages content"
                :disable="importing"
                @update:model-value="parsePastedData"
              />
            </q-tab-panel>
          </q-tab-panels>

          <div v-if="csvPreview.length" class="q-mt-md">
            <div class="text-subtitle2 q-mb-sm">
              Preview ({{ csvPreview.length }} rows)
              <q-badge
                v-if="duplicateCount > 0"
                color="warning"
                class="q-ml-sm"
                :label="`${duplicateCount} duplicate${duplicateCount > 1 ? 's' : ''}`"
              />
              <q-badge
                v-if="newCount > 0"
                color="positive"
                class="q-ml-sm"
                :label="`${newCount} new`"
              />
            </div>
            <q-table
              :rows="csvPreview.slice(0, 10)"
              :columns="csvColumns"
              row-key="__index"
              flat
              dense
              :rows-per-page-options="[0]"
            >
              <template v-slot:body-cell-code="props">
                <q-td :props="props">
                  <div class="row items-center q-gutter-xs">
                    <span>{{ props.value || '(no code)' }}</span>
                    <q-icon
                      v-if="props.row.__isDuplicate"
                      name="warning"
                      color="warning"
                      size="sm"
                      :title="`Duplicate: Will update existing glaze with code '${props.value}'`"
                    />
                    <q-icon
                      v-else-if="props.value"
                      name="check_circle"
                      color="positive"
                      size="sm"
                      title="New glaze"
                    />
                  </div>
                </q-td>
              </template>
              <template v-slot:body-cell-name="props">
                <q-td :props="props">
                  <div>{{ props.value || '-' }}</div>
                  <div v-if="props.row.__existingGlaze" class="text-caption text-grey-7">
                    Existing: {{ props.row.__existingGlaze.name || '-' }}
                  </div>
                </q-td>
              </template>
            </q-table>
            <div v-if="csvPreview.length > 10" class="text-caption text-grey-7 q-mt-xs">
              ... and {{ csvPreview.length - 10 }} more rows
            </div>
          </div>

          <div v-if="importResults" class="q-mt-md">
            <q-banner
              :class="importResults.failed > 0 ? 'bg-warning' : 'bg-positive'"
              rounded
            >
              <template v-slot:avatar>
                <q-icon
                  :name="importResults.failed > 0 ? 'warning' : 'check_circle'"
                  color="white"
                />
              </template>
              <div class="text-white">
                <div class="text-weight-bold">
                  Import complete: {{ importResults.success }} succeeded,
                  {{ importResults.failed }} failed
                </div>
                <div v-if="importResults.errors.length" class="q-mt-sm">
                  <div
                    v-for="(err, idx) in importResults.errors.slice(0, 5)"
                    :key="idx"
                    class="text-caption"
                  >
                    Code "{{ err.code }}": {{ err.error }}
                  </div>
                  <div v-if="importResults.errors.length > 5" class="text-caption">
                    ... and {{ importResults.errors.length - 5 }} more errors
                  </div>
                </div>
              </div>
            </q-banner>
          </div>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancel" :disable="importing" @click="closeImportDialog" />
          <q-btn
            color="primary"
            label="Import"
            :loading="importing"
            :disable="!csvPreview.length || importing"
            @click="importGlazes"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useQuasar } from 'quasar'
import { useGlazesStore } from 'src/stores/glazes'

const $q = useQuasar()
const glazesStore = useGlazesStore()

const search = ref('')
const editingId = ref(null)
const editingField = ref(null)
const editingValue = ref('')
const isLoading = ref(false)

// Pages editing
const pagesDialog = ref(false)
const editingPagesGlaze = ref(null)
const pagesValue = ref('')

// CSV Import
const importDialog = ref(false)
const importTab = ref('file')
const csvFile = ref(null)
const pastedData = ref('')
const csvPreview = ref([])
const importing = ref(false)
const importResults = ref(null)
const csvColumns = [
  { name: 'code', label: 'Code', field: 'code', align: 'left' },
  { name: 'name', label: 'Name', field: 'name', align: 'left' },
  { name: 'brand', label: 'Brand', field: 'brand', align: 'left' },
  { name: 'color', label: 'Color', field: 'color', align: 'left' },
]

const columns = [
  { name: 'code', label: 'Code', field: 'code', align: 'left', sortable: true },
  { name: 'name', label: 'Name', field: 'name', align: 'left', sortable: true },
  { name: 'brand', label: 'Brand', field: 'brand', align: 'left', sortable: true },
  { name: 'color', label: 'Color', field: 'color', align: 'left', sortable: true },
  { name: 'cone', label: 'Cone', field: 'cone', align: 'center', sortable: true },
  { name: 'series', label: 'Series', field: 'series', align: 'left', sortable: true },
  { name: 'finish', label: 'Finish', field: 'finish', align: 'left', sortable: true },
  { name: 'display_name', label: 'Display Name', field: 'display_name', align: 'left', sortable: true },
  { name: 'notes', label: 'Notes', field: 'notes', align: 'left', sortable: false },
  { name: 'pages', label: 'Pages', field: 'pages', align: 'left', sortable: false },
]

const filteredGlazes = computed(() => {
  const allGlazes = glazesStore.all?.value || []
  if (!Array.isArray(allGlazes) || allGlazes.length === 0) {
    return []
  }

  // Create a copy of the array to avoid mutating the read-only reactive array
  const glazes = [...allGlazes]
  const searchLower = search.value.trim().toLowerCase()

  if (!searchLower) {
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

function startEdit(id, field, value) {
  editingId.value = id
  editingField.value = field
  editingValue.value = value || ''
}

function cancelEdit() {
  editingId.value = null
  editingField.value = null
  editingValue.value = ''
}

async function saveEdit(id, field, value) {
  if (editingId.value !== id || editingField.value !== field) {
    return
  }

  const originalGlaze = glazesStore.all?.value?.find((g) => g.id === id)
  if (!originalGlaze) {
    cancelEdit()
    return
  }

  // Normalize the value
  let normalizedValue = value
  if (field === 'cone') {
    normalizedValue = value === '' || value === null ? null : Number(value)
  } else {
    normalizedValue = value === '' ? null : String(value).trim()
  }

  // Check if value actually changed
  if (originalGlaze[field] === normalizedValue) {
    cancelEdit()
    return
  }

  isLoading.value = true
  try {
    await glazesStore.updateGlaze(id, { [field]: normalizedValue })
    await glazesStore.refetch()
    $q.notify({
      type: 'positive',
      message: `${field} updated successfully`,
      position: 'top',
      timeout: 2000,
    })
  } catch (error) {
    console.error('Error updating glaze:', error)
    $q.notify({
      type: 'negative',
      message: `Failed to update ${field}: ${error.message || 'Unknown error'}`,
      position: 'top',
      timeout: 3000,
    })
  } finally {
    isLoading.value = false
    cancelEdit()
  }
}

function downloadCSV() {
  const glazes = filteredGlazes.value || []
  
  if (glazes.length === 0) {
    $q.notify({
      type: 'warning',
      message: 'No glazes to download',
      position: 'top',
      timeout: 2000,
    })
    return
  }

  // Define CSV columns
  const columns = [
    'code',
    'name',
    'brand',
    'color',
    'cone',
    'series',
    'finish',
    'display_name',
    'notes',
    'pages',
  ]

  // Escape CSV values (handle commas, quotes, newlines)
  function escapeCSV(value) {
    if (value === null || value === undefined) {
      return ''
    }
    const str = String(value)
    // If contains comma, quote, or newline, wrap in quotes and escape quotes
    if (str.includes(',') || str.includes('"') || str.includes('\n')) {
      return `"${str.replace(/"/g, '""')}"`
    }
    return str
  }

  // Create CSV header
  const header = columns.map((col) => escapeCSV(col)).join(',')

  // Create CSV rows
  const rows = glazes.map((glaze) => {
    return columns.map((col) => escapeCSV(glaze[col] || '')).join(',')
  })

  // Combine header and rows
  const csvContent = [header, ...rows].join('\n')

  // Create blob and download
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)
  
  link.setAttribute('href', url)
  link.setAttribute('download', `glazes_${new Date().toISOString().split('T')[0]}.csv`)
  link.style.visibility = 'hidden'
  
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  
  // Clean up the URL object
  URL.revokeObjectURL(url)

  $q.notify({
    type: 'positive',
    message: `Downloaded ${glazes.length} glazes as CSV`,
    position: 'top',
    timeout: 2000,
  })
}

// Create a map of glaze codes to glaze objects for duplicate detection
const glazeCodeMap = computed(() => {
  const map = new Map()
  const allGlazes = glazesStore.all?.value || []
  if (Array.isArray(allGlazes)) {
    allGlazes.forEach((glaze) => {
      if (glaze && glaze.code) {
        map.set(String(glaze.code).trim().toLowerCase(), glaze)
      }
    })
  }
  return map
})

const duplicateCount = computed(() => {
  return csvPreview.value.filter((row) => row.__isDuplicate).length
})

const newCount = computed(() => {
  return csvPreview.value.filter((row) => !row.__isDuplicate && row.code).length
})

// CSV Parsing Functions
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
    
    // Check for duplicates
    const code = row.code?.trim()
    if (code) {
      const codeLower = code.toLowerCase()
      const existing = glazeCodeMap.value.get(codeLower)
      if (existing) {
        row.__isDuplicate = true
        row.__existingGlaze = existing
      } else {
        row.__isDuplicate = false
      }
    } else {
      row.__isDuplicate = false
    }
    
    rows.push(row)
  }

  return rows
}

async function handleFileUpload() {
  if (!csvFile.value) {
    csvPreview.value = []
    importResults.value = null
    return
  }

  try {
    // Ensure glazes are loaded for duplicate detection
    const all = glazesStore.all?.value || []
    if (!all.length) {
      await glazesStore.refetch()
    }

    const text = await csvFile.value.text()
    csvPreview.value = parseCSVText(text)
    importResults.value = null
  } catch (error) {
    console.error('File parsing error:', error)
    csvPreview.value = []
    importResults.value = {
      success: 0,
      failed: 0,
      errors: [{ code: 'N/A', error: error.message || 'Failed to parse file' }],
    }
  }
}

async function parsePastedData() {
  if (!pastedData.value.trim()) {
    csvPreview.value = []
    importResults.value = null
    return
  }

  try {
    // Ensure glazes are loaded for duplicate detection
    const all = glazesStore.all?.value || []
    if (!all.length) {
      await glazesStore.refetch()
    }

    csvPreview.value = parseCSVText(pastedData.value)
    importResults.value = null
  } catch (error) {
    console.error('Parsing error:', error)
    csvPreview.value = []
    importResults.value = {
      success: 0,
      failed: 0,
      errors: [{ code: 'N/A', error: error.message || 'Failed to parse data' }],
    }
  }
}

async function importGlazes() {
  if (!csvPreview.value.length) return

  importing.value = true
  importResults.value = null

  try {
    // Ensure glazes are loaded and refresh the map
    await glazesStore.refetch()
    
    // Rebuild the code map to ensure it's current
    const allGlazes = glazesStore.all?.value || []
    const codeMap = new Map()
    if (Array.isArray(allGlazes)) {
      allGlazes.forEach((glaze) => {
        if (glaze && glaze.code) {
          codeMap.set(String(glaze.code).trim().toLowerCase(), glaze)
        }
      })
    }

    const results = {
      success: 0,
      failed: 0,
      errors: [],
    }

    // Track codes we've processed in this batch to handle duplicates within the CSV
    const processedInBatch = new Map()

    for (const row of csvPreview.value) {
      const code = row.code?.trim()
      if (!code) {
        results.failed++
        results.errors.push({ code: 'N/A', error: 'Missing code' })
        continue
      }

      const codeLower = code.toLowerCase()
      
      // Check if we've already processed this code in this batch
      if (processedInBatch.has(codeLower)) {
        // This is a duplicate within the CSV - update the existing one
        const existingInBatch = processedInBatch.get(codeLower)
        if (existingInBatch.id) {
          // We have an ID, so update it
          // Only include fields that can be set
          const glazeData = {}
          if (code) glazeData.code = code
          if (row.name) glazeData.name = row.name.trim() || null
          if (row.brand !== undefined) glazeData.brand = row.brand?.trim() || null
          if (row.color !== undefined) glazeData.color = row.color?.trim() || null
          if (row.cone !== undefined) {
            glazeData.cone = row.cone ? (isNaN(Number(row.cone)) ? null : Number(row.cone)) : null
          }
          if (row.series !== undefined) glazeData.series = row.series?.trim() || null
          if (row.finish !== undefined) glazeData.finish = row.finish?.trim() || null
          if (row.notes !== undefined) glazeData.notes = row.notes?.trim() || null
          if (row.pages !== undefined) glazeData.pages = row.pages?.trim() || null
          
          try {
            await glazesStore.updateGlaze(existingInBatch.id, glazeData)
            results.success++
            // Update the tracking map with the latest data
            processedInBatch.set(codeLower, { ...existingInBatch, ...glazeData })
            // Also update the codeMap
            const updatedGlaze = { ...codeMap.get(codeLower), ...glazeData }
            codeMap.set(codeLower, updatedGlaze)
          } catch (error) {
            results.failed++
            results.errors.push({
              code,
              error: error instanceof Error ? error.message : 'Unknown error',
            })
          }
        } else {
          // No ID yet, skip this duplicate row (first one already processed)
          results.failed++
          results.errors.push({
            code,
            error: 'Duplicate code in CSV (already processed)',
          })
        }
        continue
      }

      // Check if it exists in the database
      const existing = codeMap.get(codeLower)
      
      // Debug: Log if we're about to create but code might exist
      if (!existing && codeMap.size > 0) {
        // Check if code exists with different case/whitespace
        const allCodes = Array.from(codeMap.keys())
        const matchingCode = allCodes.find(c => c === codeLower)
        if (!matchingCode) {
          // Check for similar codes (debugging)
          console.log(`[Import] Code "${code}" not found in map. Map has ${codeMap.size} entries.`)
          console.log(`[Import] Sample codes in map:`, allCodes.slice(0, 5))
        }
      }

      // Prepare glaze data - only include fields that can be set
      // Note: display_name is a GENERATED column (computed from name and code), so we don't include it
      // Note: id is auto-generated, so we never include it
      // Only include allowed fields to prevent any unexpected fields from being passed
      const glazeData = {}
      if (code) glazeData.code = code
      if (row.name) glazeData.name = row.name.trim() || null
      if (row.brand !== undefined) glazeData.brand = row.brand?.trim() || null
      if (row.color !== undefined) glazeData.color = row.color?.trim() || null
      if (row.cone !== undefined) {
        glazeData.cone = row.cone ? (isNaN(Number(row.cone)) ? null : Number(row.cone)) : null
      }
      if (row.series !== undefined) glazeData.series = row.series?.trim() || null
      if (row.finish !== undefined) glazeData.finish = row.finish?.trim() || null
      if (row.notes !== undefined) glazeData.notes = row.notes?.trim() || null
      if (row.pages !== undefined) glazeData.pages = row.pages?.trim() || null

      try {
        if (existing) {
          // Update existing glaze
          await glazesStore.updateGlaze(existing.id, glazeData)
          results.success++
          // Track it in our batch map
          processedInBatch.set(codeLower, { ...existing, ...glazeData })
        } else {
          // Try to create new glaze
          try {
            const newGlaze = await glazesStore.createGlaze(glazeData)
            if (newGlaze && newGlaze.id) {
              results.success++
              // Track it in our batch map
              processedInBatch.set(codeLower, newGlaze)
              // Add it to the codeMap for subsequent rows
              codeMap.set(codeLower, newGlaze)
            } else {
              throw new Error('Failed to create glaze - no ID returned')
            }
          } catch (createError) {
            // If create fails with uniqueness violation, the glaze might exist
            // Try to find it again and update instead
            const errorMsg = createError instanceof Error ? createError.message : String(createError)
            if (errorMsg.includes('unique') || errorMsg.includes('duplicate') || errorMsg.includes('violates')) {
              // Refetch glazes and check again
              await glazesStore.refetch()
              const refreshedGlazes = glazesStore.all?.value || []
              const refreshedMap = new Map()
              if (Array.isArray(refreshedGlazes)) {
                refreshedGlazes.forEach((glaze) => {
                  if (glaze && glaze.code) {
                    refreshedMap.set(String(glaze.code).trim().toLowerCase(), glaze)
                  }
                })
              }
              const found = refreshedMap.get(codeLower)
              if (found) {
                // Found it! Update instead
                await glazesStore.updateGlaze(found.id, glazeData)
                results.success++
                processedInBatch.set(codeLower, { ...found, ...glazeData })
                codeMap.set(codeLower, { ...found, ...glazeData })
              } else {
                // Still not found, throw the original error
                throw createError
              }
            } else {
              // Different error, throw it
              throw createError
            }
          }
        }
      } catch (error) {
        results.failed++
        results.errors.push({
          code,
          error: error instanceof Error ? error.message : 'Unknown error',
        })
      }
    }

    importResults.value = results

    if (results.success > 0) {
      // Refresh the glazes list
      await glazesStore.refetch()
    }
  } catch (error) {
    console.error('Import error:', error)
    importResults.value = {
      success: 0,
      failed: csvPreview.value.length,
      errors: [{ code: 'N/A', error: error instanceof Error ? error.message : 'Import failed' }],
    }
  } finally {
    importing.value = false
  }
}

function closeImportDialog() {
  importDialog.value = false
  csvFile.value = null
  pastedData.value = ''
  csvPreview.value = []
  importResults.value = null
  importTab.value = 'file'
}

function openPagesDialog(glaze) {
  editingPagesGlaze.value = glaze
  pagesValue.value = glaze.pages || ''
  pagesDialog.value = true
}

function closePagesDialog() {
  pagesDialog.value = false
  editingPagesGlaze.value = null
  pagesValue.value = ''
}

async function savePages() {
  if (!editingPagesGlaze.value) return

  isLoading.value = true
  try {
    const normalizedValue = pagesValue.value.trim() || null
    await glazesStore.updateGlaze(editingPagesGlaze.value.id, { pages: normalizedValue })
    await glazesStore.refetch()
    $q.notify({
      type: 'positive',
      message: 'Pages updated successfully',
      position: 'top',
      timeout: 2000,
    })
    closePagesDialog()
  } catch (error) {
    console.error('Error updating pages:', error)
    $q.notify({
      type: 'negative',
      message: `Failed to update pages: ${error.message || 'Unknown error'}`,
      position: 'top',
      timeout: 3000,
    })
  } finally {
    isLoading.value = false
  }
}

onMounted(async () => {
  isLoading.value = true
  try {
    await glazesStore.refetch()
  } catch (error) {
    console.error('Error loading glazes:', error)
    $q.notify({
      type: 'negative',
      message: 'Failed to load glazes',
      position: 'top',
    })
  } finally {
    isLoading.value = false
  }
})
</script>

<style scoped>
.all-glazes-page {
  max-width: 1400px;
  margin: 0 auto;
}

.editable-field {
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
  display: inline-flex;
  align-items: center;
}

.editable-field:hover {
  background-color: rgba(0, 0, 0, 0.05);
}

.editable-field .q-icon {
  opacity: 0;
  transition: opacity 0.2s;
}

.editable-field:hover .q-icon {
  opacity: 1;
}
</style>

