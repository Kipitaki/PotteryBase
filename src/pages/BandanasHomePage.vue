<template>
  <q-page padding class="bg-grey-1 bandanas-page">
    <div class="row items-center justify-between q-mb-md">
      <div>
        <div class="text-h4 text-weight-bold">Bandanas Management</div>
        <div class="text-caption text-grey-7 q-mt-xs">
          Manage buyers, addresses, events, and orders
        </div>
      </div>
      <div class="row q-gutter-sm">
        <q-btn
          color="primary"
          icon="download"
          label="Export All Data"
          @click="handleExport"
          :loading="exporting"
        />
        <q-btn
          color="secondary"
          icon="upload"
          label="Import All Data"
          @click="importDialog = true"
        />
      </div>
    </div>

    <div class="row q-col-gutter-md">
      <!-- Buyers Card -->
      <div class="col-12 col-md-6 col-lg-3">
        <q-card
          class="cursor-pointer bandanas-card"
          @click="router.push({ name: 'bandanas-buyers' })"
        >
          <q-card-section>
            <div class="row items-center q-mb-sm">
              <q-icon name="people" size="48px" color="purple" class="q-mr-md" />
              <div>
                <div class="text-h6 text-weight-bold">Buyers</div>
                <div class="text-caption text-grey-7">Manage buyer information</div>
              </div>
            </div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <div class="text-body2 text-grey-7">
              Add, edit, and manage buyer profiles and contact information.
            </div>
          </q-card-section>
        </q-card>
      </div>

      <!-- Addresses Card -->
      <div class="col-12 col-md-6 col-lg-3">
        <q-card
          class="cursor-pointer bandanas-card"
          @click="router.push({ name: 'bandanas-addresses' })"
        >
          <q-card-section>
            <div class="row items-center q-mb-sm">
              <q-icon name="home" size="48px" color="purple" class="q-mr-md" />
              <div>
                <div class="text-h6 text-weight-bold">Addresses</div>
                <div class="text-caption text-grey-7">Shipping addresses</div>
              </div>
            </div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <div class="text-body2 text-grey-7">Manage shipping addresses for buyers.</div>
          </q-card-section>
        </q-card>
      </div>

      <!-- Events Card -->
      <div class="col-12 col-md-6 col-lg-3">
        <q-card
          class="cursor-pointer bandanas-card"
          @click="router.push({ name: 'bandanas-events' })"
        >
          <q-card-section>
            <div class="row items-center q-mb-sm">
              <q-icon name="event" size="48px" color="purple" class="q-mr-md" />
              <div>
                <div class="text-h6 text-weight-bold">Events</div>
                <div class="text-caption text-grey-7">Bandana events & pricing</div>
              </div>
            </div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <div class="text-body2 text-grey-7">Manage events, pricing, and availability.</div>
          </q-card-section>
        </q-card>
      </div>

      <!-- Orders Card -->
      <div class="col-12 col-md-6 col-lg-3">
        <q-card
          class="cursor-pointer bandanas-card"
          @click="router.push({ name: 'bandanas-orders' })"
        >
          <q-card-section>
            <div class="row items-center q-mb-sm">
              <q-icon name="shopping_cart" size="48px" color="purple" class="q-mr-md" />
              <div>
                <div class="text-h6 text-weight-bold">Orders</div>
                <div class="text-caption text-grey-7">Customer orders</div>
              </div>
            </div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <div class="text-body2 text-grey-7">View and manage customer orders.</div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Import Dialog -->
    <q-dialog v-model="importDialog" persistent>
      <q-card style="min-width: 600px; max-width: 800px">
        <q-card-section>
          <div class="text-h6">Import All Bandanas Data</div>
          <div class="text-caption text-grey-7 q-mt-xs">
            Upload a CSV file exported from another instance. This will import buyers, events,
            addresses, orders, and shipping rates.
          </div>
        </q-card-section>

        <q-card-section>
          <q-file
            v-model="importFile"
            label="Choose CSV file"
            accept=".csv,text/csv"
            outlined
            :disable="importing"
            @update:model-value="handleFileSelect"
          >
            <template v-slot:prepend>
              <q-icon name="attach_file" />
            </template>
          </q-file>
        </q-card-section>

        <q-card-section v-if="importResults" class="q-pt-none">
          <div class="text-subtitle2 q-mb-sm">Import Results:</div>
          <div class="q-gutter-sm">
            <div>
              <strong>Buyers:</strong> {{ importResults.buyers.success }} succeeded,
              {{ importResults.buyers.failed }} failed
            </div>
            <div>
              <strong>Events:</strong> {{ importResults.events.success }} succeeded,
              {{ importResults.events.failed }} failed
            </div>
            <div>
              <strong>Addresses:</strong> {{ importResults.addresses.success }} succeeded,
              {{ importResults.addresses.failed }} failed
            </div>
            <div>
              <strong>Orders:</strong> {{ importResults.orders.success }} succeeded,
              {{ importResults.orders.failed }} failed
            </div>
            <div>
              <strong>Shipping Rates:</strong> {{ importResults.shipping_rates.success }} succeeded,
              {{ importResults.shipping_rates.failed }} failed
            </div>
          </div>

          <div
            v-if="
              importResults.buyers.errors.length > 0 ||
              importResults.events.errors.length > 0 ||
              importResults.addresses.errors.length > 0 ||
              importResults.orders.errors.length > 0 ||
              importResults.shipping_rates.errors.length > 0
            "
            class="q-mt-md"
          >
            <div class="text-subtitle2 text-negative q-mb-sm">Errors:</div>
            <q-scroll-area style="height: 200px" class="border">
              <div v-for="(error, idx) in allImportErrors" :key="idx" class="text-caption q-pa-xs">
                <strong>Row {{ error.row }}:</strong> {{ error.error }}
              </div>
            </q-scroll-area>
          </div>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn
            flat
            label="Cancel"
            color="primary"
            @click="closeImportDialog"
            :disable="importing"
          />
          <q-btn
            flat
            label="Import"
            color="primary"
            @click="handleImport"
            :loading="importing"
            :disable="!importFile"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { useBandanasDataExport } from 'src/composables/useBandanasDataExport'
import { useBandanasDataImport } from 'src/composables/useBandanasDataImport'

const router = useRouter()
const $q = useQuasar()

const { exportAllData } = useBandanasDataExport()
const { importAllData } = useBandanasDataImport()

const exporting = ref(false)
const importDialog = ref(false)
const importFile = ref(null)
const importing = ref(false)
const importResults = ref(null)

const allImportErrors = computed(() => {
  if (!importResults.value) return []
  const errors = []
  if (importResults.value.buyers.errors.length > 0) {
    errors.push(...importResults.value.buyers.errors.map((e) => ({ ...e, section: 'Buyers' })))
  }
  if (importResults.value.events.errors.length > 0) {
    errors.push(...importResults.value.events.errors.map((e) => ({ ...e, section: 'Events' })))
  }
  if (importResults.value.addresses.errors.length > 0) {
    errors.push(
      ...importResults.value.addresses.errors.map((e) => ({ ...e, section: 'Addresses' })),
    )
  }
  if (importResults.value.orders.errors.length > 0) {
    errors.push(...importResults.value.orders.errors.map((e) => ({ ...e, section: 'Orders' })))
  }
  if (importResults.value.shipping_rates.errors.length > 0) {
    errors.push(
      ...importResults.value.shipping_rates.errors.map((e) => ({
        ...e,
        section: 'Shipping Rates',
      })),
    )
  }
  return errors
})

async function handleExport() {
  exporting.value = true
  try {
    const result = await exportAllData()
    $q.notify({
      type: 'positive',
      message: `Export completed! Exported ${result.buyers} buyers, ${result.events} events, ${result.addresses} addresses, ${result.orders} orders, and ${result.shippingRates} shipping rates.`,
      timeout: 5000,
    })
  } catch (error) {
    console.error('Export error:', error)
    $q.notify({
      type: 'negative',
      message: `Export failed: ${error.message || 'Unknown error'}`,
    })
  } finally {
    exporting.value = false
  }
}

function handleFileSelect() {
  importResults.value = null
}

async function handleImport() {
  if (!importFile.value) return

  importing.value = true
  importResults.value = null

  try {
    const text = await importFile.value.text()
    const results = await importAllData(text)

    importResults.value = results

    const totalSuccess =
      results.buyers.success +
      results.events.success +
      results.addresses.success +
      results.orders.success +
      results.shipping_rates.success

    const totalFailed =
      results.buyers.failed +
      results.events.failed +
      results.addresses.failed +
      results.orders.failed +
      results.shipping_rates.failed

    if (totalFailed === 0) {
      $q.notify({
        type: 'positive',
        message: `Import completed successfully! ${totalSuccess} records imported.`,
        timeout: 5000,
      })
    } else {
      $q.notify({
        type: 'warning',
        message: `Import completed with ${totalSuccess} succeeded and ${totalFailed} failed.`,
        timeout: 5000,
      })
    }
  } catch (error) {
    console.error('Import error:', error)
    $q.notify({
      type: 'negative',
      message: `Import failed: ${error.message || 'Unknown error'}`,
    })
  } finally {
    importing.value = false
  }
}

function closeImportDialog() {
  importDialog.value = false
  importFile.value = null
  importResults.value = null
}
</script>

<style scoped>
.bandanas-card {
  transition:
    transform 0.2s,
    box-shadow 0.2s;
}

.bandanas-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(156, 39, 176, 0.3);
}

.border {
  border: 1px solid rgba(0, 0, 0, 0.12);
  border-radius: 4px;
}
</style>
