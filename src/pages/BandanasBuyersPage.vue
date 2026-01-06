<template>
  <q-page padding class="bg-grey-1 bandanas-page">
    <div class="row items-center justify-between q-mb-md">
      <div>
        <div class="text-h5 text-weight-bold">Buyers</div>
        <div class="text-caption text-grey-7 q-mt-xs">
          Manage buyer information
        </div>
      </div>
      <div class="row q-gutter-sm">
        <q-btn
          color="purple"
          icon="upload_file"
          label="Import CSV"
          @click="csvDialog = true"
        />
        <q-btn
          color="purple"
          icon="add"
          label="Add Buyer"
          @click="router.push({ name: 'bandanas-buyer-edit', params: { id: 'new' } })"
        />
      </div>
    </div>

    <div class="row q-mb-md">
      <q-input
        v-model="buyerSearchQuery"
        outlined
        dense
        clearable
        label="Search buyers"
        placeholder="Search by name, email, etc."
        prepend-inner-icon="search"
        class="col-12 col-md-6"
      />
    </div>

    <q-table
      :rows="filteredBuyers"
      :columns="columns"
      row-key="id"
      :loading="buyersStore.loading.value"
      flat
      bordered
      :rows-per-page-options="[100]"
      :pagination="{ rowsPerPage: 100 }"
    >
      <template v-slot:body-cell-actions="props">
        <q-td :props="props">
          <q-btn
            flat
            dense
            round
            icon="edit"
            color="purple"
            @click="router.push({ name: 'bandanas-buyer-edit', params: { id: props.row.id } })"
          />
          <q-btn
            flat
            dense
            round
            icon="delete"
            color="negative"
            @click="confirmDelete(props.row)"
          />
        </q-td>
      </template>
    </q-table>
  </q-page>

  <!-- Import CSV Dialog -->
  <q-dialog v-model="csvDialog" persistent>
    <q-card style="min-width: 600px; max-width: 800px">
      <q-card-section>
        <div class="text-h6">Import Buyers from CSV</div>
        <div class="text-caption text-grey-7 q-mt-xs">
          Upload a file or paste CSV data. Must include <code>first_name</code> and
          <code>last_name</code> columns. Optional: <code>email</code>.
        </div>
      </q-card-section>

      <q-card-section>
        <q-tabs v-model="importTab" class="text-grey" active-color="purple">
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
              placeholder="first_name,last_name,email&#10;John,Doe,john.doe@example.com&#10;Jane,Smith,jane.smith@example.com"
              :disable="csvImporting"
              @update:model-value="parsePastedData"
            />
          </q-tab-panel>
        </q-tab-panels>

        <div v-if="csvPreview.length" class="q-mt-md">
          <div class="text-subtitle2 q-mb-sm">
            Preview ({{ csvPreview.length }} rows)
          </div>
          <q-table
            :rows="csvPreview.slice(0, 10)"
            :columns="csvColumns"
            row-key="__index"
            flat
            bordered
            dense
            :rows-per-page-options="[0]"
            hide-pagination
          />
          <div v-if="csvPreview.length > 10" class="text-caption text-grey-7 q-mt-xs">
            ... and {{ csvPreview.length - 10 }} more rows
          </div>
        </div>

        <div v-if="csvImportResults" class="q-mt-md">
          <q-banner
            :class="csvImportResults.failed > 0 ? 'bg-warning' : 'bg-positive'"
            rounded
          >
            <template v-slot:avatar>
              <q-icon
                :name="csvImportResults.failed > 0 ? 'warning' : 'check_circle'"
                :color="csvImportResults.failed > 0 ? 'warning' : 'positive'"
              />
            </template>
            <div>
              Import complete: {{ csvImportResults.success }} succeeded,
              {{ csvImportResults.failed }} failed
            </div>
            <div v-if="csvImportResults.errors.length" class="q-mt-sm">
              <div
                v-for="(err, idx) in csvImportResults.errors.slice(0, 5)"
                :key="idx"
                class="text-caption"
              >
                Row {{ err.row }}: {{ err.error }}
              </div>
              <div v-if="csvImportResults.errors.length > 5" class="text-caption">
                ... and {{ csvImportResults.errors.length - 5 }} more errors
              </div>
            </div>
          </q-banner>
        </div>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn flat label="Cancel" color="purple" :disable="csvImporting" @click="closeCsvDialog" />
        <q-btn
          flat
          label="Import"
          color="purple"
          :loading="csvImporting"
          :disable="!csvPreview.length || csvImporting"
          @click="importCSV"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>

  <q-dialog v-model="showDeleteConfirm" persistent>
    <q-card>
      <q-card-section>
        <div class="text-h6">Delete Buyer</div>
      </q-card-section>
      <q-card-section>
        Are you sure you want to delete {{ buyerToDelete?.first_name }} {{ buyerToDelete?.last_name }}?
      </q-card-section>
      <q-card-actions align="right">
        <q-btn flat label="Cancel" color="purple" v-close-popup />
        <q-btn
          flat
          label="Delete"
          color="negative"
          :loading="deleting"
          @click="handleDelete"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>

</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useBuyersStore } from 'src/stores/bandanas/buyers'
import { useQuasar } from 'quasar'

const router = useRouter()
const $q = useQuasar()
const buyersStore = useBuyersStore()

const showDeleteConfirm = ref(false)
const buyerToDelete = ref(null)
const deleting = ref(false)

// CSV Import
const csvDialog = ref(false)
const importTab = ref('file')
const csvFile = ref(null)
const pastedData = ref('')
const csvPreview = ref([])
const csvImporting = ref(false)
const csvImportResults = ref(null)
const buyerSearchQuery = ref('')

const csvColumns = [
  {
    name: 'buyer_id',
    label: 'Buyer ID',
    field: 'buyer_id',
    align: 'left',
  },
  {
    name: 'first_name',
    label: 'First Name',
    field: 'first_name',
    align: 'left',
  },
  {
    name: 'last_name',
    label: 'Last Name',
    field: 'last_name',
    align: 'left',
  },
  {
    name: 'email',
    label: 'Email',
    field: 'email',
    align: 'left',
  },
]

const columns = [
  {
    name: 'first_name',
    label: 'First Name',
    field: 'first_name',
    align: 'left',
    sortable: true,
  },
  {
    name: 'last_name',
    label: 'Last Name',
    field: 'last_name',
    align: 'left',
    sortable: true,
  },
  {
    name: 'email',
    label: 'Email',
    field: 'email',
    align: 'left',
    sortable: true,
  },
  {
    name: 'created_at',
    label: 'Created',
    field: 'created_at',
    align: 'left',
    sortable: true,
    format: (val) => new Date(val).toLocaleDateString(),
  },
  {
    name: 'actions',
    label: 'Actions',
    field: 'actions',
    align: 'center',
  },
]

const filteredBuyers = computed(() => {
  const query = buyerSearchQuery.value.trim().toLowerCase()
  if (!query) {
    return buyersStore.buyers.value
  }
  return buyersStore.buyers.value.filter((buyer) => {
    const name = `${buyer.first_name || ''} ${buyer.last_name || ''}`.trim()
    const targets = [name, buyer.email]
    return targets.some((target) => (target || '').toLowerCase().includes(query))
  })
})

function confirmDelete(buyer) {
  buyerToDelete.value = buyer
  showDeleteConfirm.value = true
}

async function handleDelete() {
  if (!buyerToDelete.value) return
  deleting.value = true
  try {
    await buyersStore.deleteBuyer(buyerToDelete.value.id)
    $q.notify({
      type: 'positive',
      message: 'Buyer deleted successfully',
    })
    showDeleteConfirm.value = false
    buyerToDelete.value = null
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Error deleting buyer: ' + error.message,
    })
  } finally {
    deleting.value = false
  }
}


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

  // Parse header and normalize column names (handle spaces, underscores, case)
  const rawHeaders = parseCSVLine(lines[0])
  const headers = rawHeaders.map((h) => {
    // Normalize: remove quotes, lowercase, replace spaces with underscores
    return h.replace(/^"|"$/g, '').toLowerCase().trim().replace(/\s+/g, '_')
  })
  
  // Find required columns (handle various formats)
  const firstNameIndex = headers.findIndex((h) => 
    h === 'first_name' || h === 'firstname' || h === 'first'
  )
  const lastNameIndex = headers.findIndex((h) => 
    h === 'last_name' || h === 'lastname' || h === 'last'
  )
  
  if (firstNameIndex === -1 || lastNameIndex === -1) {
    throw new Error('CSV must have "First Name" (or "first_name") and "Last Name" (or "last_name") columns')
  }

  // Parse rows
  const rows = []
  for (let i = 1; i < lines.length; i++) {
    const values = parseCSVLine(lines[i])
    if (values.length === 0 || values.every((v) => !v || !v.trim())) continue // Skip empty rows
    
    const row = { __index: i - 1 }
    headers.forEach((header, idx) => {
      // Remove quotes from values
      const value = values[idx] || ''
      row[header] = value.replace(/^"|"$/g, '').trim()
    })
    
    // Normalize field names (handle various column name formats)
    row.first_name = row.first_name || row.firstname || row.first || ''
    row.last_name = row.last_name || row.lastname || row.last || ''
    row.email = row.email || ''
    row.buyer_id = row.buyer_id || row.buyerid || row.id || ''
    
    rows.push(row)
  }

  return rows
}

async function handleFileUpload() {
  if (!csvFile.value) {
    csvPreview.value = []
    csvImportResults.value = null
    return
  }

  try {
    const text = await csvFile.value.text()
    csvPreview.value = parseCSVText(text)
    csvImportResults.value = null
  } catch (error) {
    console.error('File parsing error:', error)
    csvPreview.value = []
    csvImportResults.value = {
      success: 0,
      failed: 0,
      errors: [{ row: 'N/A', error: error.message || 'Failed to parse file' }],
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
    csvPreview.value = parseCSVText(pastedData.value)
    csvImportResults.value = null
  } catch (error) {
    console.error('Parsing error:', error)
    csvPreview.value = []
    csvImportResults.value = {
      success: 0,
      failed: 0,
      errors: [{ row: 'N/A', error: error.message || 'Failed to parse data' }],
    }
  }
}

async function importCSV() {
  if (!csvPreview.value.length) return

  csvImporting.value = true
  csvImportResults.value = null

  try {
    const results = {
      success: 0,
      failed: 0,
      errors: [],
    }

    for (const row of csvPreview.value) {
      try {
        const first_name = (row.first_name || '').trim()
        const last_name = (row.last_name || '').trim()
        const email = (row.email || '').trim() || null
        const buyer_id = (row.buyer_id || '').trim()

        if (!first_name || !last_name) {
          results.failed++
          results.errors.push({
            row: row.__index + 1,
            error: 'First name and last name are required',
          })
          continue
        }

        // Build buyer object - store original_buyer_id for mapping addresses/orders
        const buyerData = {
          first_name,
          last_name,
          email: email || null,
          original_buyer_id: buyer_id || null,
        }

        await buyersStore.createBuyer(buyerData)

        results.success++
      } catch (error) {
        results.failed++
        results.errors.push({
          row: row.__index + 1,
          error: error.message || 'Failed to create buyer',
        })
      }
    }

    csvImportResults.value = results

    if (results.success > 0) {
      $q.notify({
        type: 'positive',
        message: `Successfully imported ${results.success} buyer(s)`,
      })
      // Refresh the buyers list
      await buyersStore.refetch()
    }
  } catch (error) {
    console.error('CSV import error:', error)
    csvImportResults.value = {
      success: 0,
      failed: csvPreview.value.length,
      errors: [{ row: 'N/A', error: error instanceof Error ? error.message : 'Import failed' }],
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

