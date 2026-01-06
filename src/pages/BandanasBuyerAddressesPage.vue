<template>
  <q-page padding class="bg-grey-1 bandanas-page">
    <div class="row items-center justify-between q-mb-md">
      <div>
        <div class="text-h5 text-weight-bold">Buyer Addresses</div>
        <div class="text-caption text-grey-7 q-mt-xs">
          Manage shipping addresses for buyers
        </div>
      </div>
      <div class="row q-gutter-sm">
        <q-btn
          color="purple"
          icon="upload_file"
          label="Import CSV"
          @click="csvDialog = true"
        />
        <!-- <q-btn
          color="negative"
          icon="delete_sweep"
          label="Delete All"
          @click="confirmDeleteAll"
          :disable="!addressesStore.buyerAddresses.value.length"
        /> -->
        <q-btn
          color="purple"
          icon="add"
          label="Add Address"
          @click="router.push({ name: 'bandanas-address-edit', params: { id: 'new' } })"
        />
      </div>
    </div>

    <div class="row q-mb-md">
      <q-input
        v-model="addressSearchQuery"
        outlined
        dense
        clearable
        label="Search addresses"
        placeholder="Search by name, email, street, city, etc."
        prepend-inner-icon="search"
        class="col-12 col-md-6"
      />
    </div>

    <q-table
      :rows="filteredAddresses"
      :columns="columns"
      row-key="id"
      :loading="addressesStore.loading.value"
      flat
      bordered
      :rows-per-page-options="[100]"
      :pagination="{ rowsPerPage: 100 }"
    >
      <template v-slot:body-cell-buyer="props">
        <q-td :props="props">
          {{ props.row.buyer?.first_name }} {{ props.row.buyer?.last_name }}
          <div class="text-caption text-grey-7">{{ props.row.buyer?.email }}</div>
        </q-td>
      </template>
      <template v-slot:body-cell-address="props">
        <q-td :props="props">
          <div>{{ props.row.address_line1 }}</div>
          <div v-if="props.row.address_line2">{{ props.row.address_line2 }}</div>
          <div>
            {{ props.row.city }}{{ props.row.state ? ', ' + props.row.state : '' }}
            {{ props.row.postal_code }}
          </div>
          <div class="text-caption text-grey-7">{{ props.row.country }}</div>
        </q-td>
      </template>
      <template v-slot:body-cell-actions="props">
        <q-td :props="props">
          <q-btn
            flat
            dense
            round
            icon="edit"
            color="purple"
            @click="router.push({ name: 'bandanas-address-edit', params: { id: props.row.id } })"
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
        <div class="text-h6">Import Addresses from CSV</div>
        <div class="text-caption text-grey-7 q-mt-xs">
          Upload a file or paste CSV data. Must include <code>Street</code> (or <code>address_line1</code>),
          <code>City</code>, <code>Postal Code</code>, and <code>BuyerId</code> columns.
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
              placeholder="Street,Street2,City,State,Postal Code,Country,BuyerId&#10;123 Main St,Apt 4,Denver,CO,80202,US,a1HgL0000002ckL"
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
        <div class="text-h6">Delete Address</div>
      </q-card-section>
      <q-card-section>
        Are you sure you want to delete this address?
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

  <q-dialog v-model="showDeleteAllConfirm" persistent>
    <q-card>
      <q-card-section>
        <div class="text-h6">Delete All Addresses</div>
      </q-card-section>
      <q-card-section>
        Are you sure you want to delete all {{ addressesStore.buyerAddresses.value.length }} addresses?
        This action cannot be undone.
      </q-card-section>
      <q-card-actions align="right">
        <q-btn flat label="Cancel" color="purple" v-close-popup />
        <q-btn
          flat
          label="Delete All"
          color="negative"
          :loading="deletingAll"
          @click="handleDeleteAll"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useBuyerAddressesStore } from 'src/stores/bandanas/buyerAddresses'
import { useBuyersStore } from 'src/stores/bandanas/buyers'
import { useQuasar } from 'quasar'

const router = useRouter()
const $q = useQuasar()
const addressesStore = useBuyerAddressesStore()
const buyersStore = useBuyersStore()

const showDeleteConfirm = ref(false)
const addressToDelete = ref(null)
const deleting = ref(false)
const showDeleteAllConfirm = ref(false)
const deletingAll = ref(false)

// CSV Import
const csvDialog = ref(false)
const importTab = ref('file')
const csvFile = ref(null)
const pastedData = ref('')
const csvPreview = ref([])
const csvImporting = ref(false)
const csvImportResults = ref(null)
const addressSearchQuery = ref('')

const csvColumns = [
  {
    name: 'buyer_id',
    label: 'Buyer ID',
    field: 'buyer_id',
    align: 'left',
  },
  {
    name: 'buyer_address_id',
    label: 'Address ID',
    field: 'buyer_address_id',
    align: 'left',
  },
  {
    name: 'address_line1',
    label: 'Street',
    field: 'address_line1',
    align: 'left',
  },
  {
    name: 'city',
    label: 'City',
    field: 'city',
    align: 'left',
  },
  {
    name: 'postal_code',
    label: 'Postal Code',
    field: 'postal_code',
    align: 'left',
  },
]

const columns = [
  {
    name: 'buyer',
    label: 'Buyer',
    field: 'buyer',
    align: 'left',
  },
  {
    name: 'address',
    label: 'Address',
    field: 'address',
    align: 'left',
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

const filteredAddresses = computed(() => {
  const query = addressSearchQuery.value.trim().toLowerCase()
  if (!query) {
    return addressesStore.buyerAddresses.value
  }

  return addressesStore.buyerAddresses.value.filter((address) => {
    const buyerName = `${address.buyer?.first_name || ''} ${address.buyer?.last_name || ''}`.trim()
    const searchTargets = [
      buyerName,
      address.buyer?.email,
      address.address_line1,
      address.address_line2,
      address.city,
      address.state,
      address.postal_code,
    ]

    return searchTargets.some((target) => (target || '').toLowerCase().includes(query))
  })
})

function confirmDelete(address) {
  addressToDelete.value = address
  showDeleteConfirm.value = true
}

// function confirmDeleteAll() {
//   showDeleteAllConfirm.value = true
// }

async function handleDelete() {
  if (!addressToDelete.value) return
  deleting.value = true
  try {
    await addressesStore.deleteBuyerAddress(addressToDelete.value.id)
    $q.notify({
      type: 'positive',
      message: 'Address deleted successfully',
    })
    showDeleteConfirm.value = false
    addressToDelete.value = null
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Error deleting address: ' + error.message,
    })
  } finally {
    deleting.value = false
  }
}

// async function handleDeleteAll() {
//   deletingAll.value = true
//   try {
//     await addressesStore.deleteAllAddresses()
//     $q.notify({
//       type: 'positive',
//       message: 'All addresses deleted successfully',
//     })
//     showDeleteAllConfirm.value = false
//   } catch (error) {
//     $q.notify({
//       type: 'negative',
//       message: 'Error deleting addresses: ' + error.message,
//     })
//   } finally {
//     deletingAll.value = false
//   }
// }

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
  const streetIndex = headers.findIndex((h) =>
    h === 'street' || h === 'address_line1' || h === 'address_line_1'
  )
  const cityIndex = headers.findIndex((h) => h === 'city')
  const postalCodeIndex = headers.findIndex((h) =>
    h === 'postal_code' || h === 'postalcode' || h === 'zip' || h === 'zip_code'
  )
  const buyerIdIndex = headers.findIndex((h) =>
    h === 'buyerid' || h === 'buyer_id' || h === 'buyer'
  )

  if (streetIndex === -1 || cityIndex === -1 || postalCodeIndex === -1 || buyerIdIndex === -1) {
    throw new Error(
      'CSV must have "Street" (or "address_line1"), "City", "Postal Code", and "BuyerId" columns'
    )
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
    row.address_line1 = row.street || row.address_line1 || row.address_line_1 || ''
    row.address_line2 = row.street2 || row.address_line2 || row.address_line_2 || ''
    row.city = row.city || ''
    row.state = row.state || ''
    row.postal_code = row.postal_code || row.postalcode || row.zip || row.zip_code || ''
    row.country = row.country || 'US'
    row.buyer_id = row.buyerid || row.buyer_id || row.buyer || ''
    row.buyer_address_id = row.buyer_address_id || row.buyeraddressid || row.address_id || ''

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
        const address_line1 = (row.address_line1 || '').trim()
        const address_line2 = (row.address_line2 || '').trim() || null
        const city = (row.city || '').trim()
        const state = (row.state || '').trim() || null
        const postal_code = (row.postal_code || '').trim()
        const country = (row.country || '').trim() || 'US'
        const buyerId = (row.buyer_id || '').trim()

        if (!address_line1 || !city || !postal_code) {
          results.failed++
          results.errors.push({
            row: row.__index + 1,
            error: 'Street, City, and Postal Code are required',
          })
          continue
        }

        if (!buyerId) {
          results.failed++
          results.errors.push({
            row: row.__index + 1,
            error: 'BuyerId is required',
          })
          continue
        }

        // Look up buyer by original_buyer_id
        const buyer = await buyersStore.getBuyerByOriginalId(buyerId)
        if (!buyer) {
          results.failed++
          results.errors.push({
            row: row.__index + 1,
            error: `Buyer with ID "${buyerId}" not found`,
          })
          continue
        }

        // Get original_address_id from "Buyer Address ID" column
        const original_address_id = (row.buyer_address_id || '').trim() || null

        await addressesStore.createBuyerAddress({
          buyer_id: buyer.id,
          address_line1,
          address_line2,
          city,
          state,
          postal_code,
          country,
          original_address_id: original_address_id || null,
        })

        results.success++
      } catch (error) {
        results.failed++
        results.errors.push({
          row: row.__index + 1,
          error: error.message || 'Failed to create address',
        })
      }
    }

    csvImportResults.value = results

    if (results.success > 0) {
      $q.notify({
        type: 'positive',
        message: `Successfully imported ${results.success} address(es)`,
      })
      // Refresh the addresses list
      await addressesStore.refetch()
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

