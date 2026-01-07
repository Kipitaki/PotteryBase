import { useBuyersStore } from 'stores/bandanas/buyers'
import { useBuyerAddressesStore } from 'stores/bandanas/buyerAddresses'
import { useEventsStore } from 'stores/bandanas/events'
import { useOrdersStore } from 'stores/bandanas/orders'
import { useShippingRatesStore } from 'stores/bandanas/shippingRates'

// Helper function to escape CSV values
function escapeCSV(value) {
  if (value === null || value === undefined) return ''
  const str = String(value)
  if (str.includes(',') || str.includes('"') || str.includes('\n')) {
    return `"${str.replace(/"/g, '""')}"`
  }
  return str
}

// Helper function to convert array to CSV
function arrayToCSV(data, headers) {
  const rows = [headers.join(',')]
  for (const row of data) {
    const values = headers.map((header) => escapeCSV(row[header] || ''))
    rows.push(values.join(','))
  }
  return rows.join('\n')
}

// Helper function to download CSV file
function downloadCSV(content, filename) {
  const blob = new Blob([content], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)
  link.setAttribute('href', url)
  link.setAttribute('download', filename)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}

export function useBandanasDataExport() {
  const buyersStore = useBuyersStore()
  const addressesStore = useBuyerAddressesStore()
  const eventsStore = useEventsStore()
  const ordersStore = useOrdersStore()
  const shippingRatesStore = useShippingRatesStore()

  async function exportAllData() {
    try {
      // Ensure all data is loaded
      await Promise.all([
        buyersStore.refetch(),
        addressesStore.refetch(),
        eventsStore.refetch(),
        ordersStore.refetch(),
        shippingRatesStore.refetch(),
      ])

      // Export buyers
      const buyers = buyersStore.buyers.value || []
      const buyersCSV = arrayToCSV(buyers, [
        'id',
        'first_name',
        'last_name',
        'email',
        'original_buyer_id',
        'created_at',
        'updated_at',
      ])

      // Export events
      const events = eventsStore.events.value || []
      const eventsCSV = arrayToCSV(events, [
        'id',
        'name',
        'year',
        'price_single',
        'price_multi',
        'active',
        'bandana_cost',
        'freight',
        'fee_tax_transaction_fees',
        'total_qty',
        'image_url',
        'freight_out',
        'created_at',
        'updated_at',
      ])

      // Export addresses
      const addresses = addressesStore.buyerAddresses.value || []
      const addressesCSV = arrayToCSV(addresses, [
        'id',
        'buyer_id',
        'address_line1',
        'address_line2',
        'city',
        'state',
        'postal_code',
        'country',
        'original_address_id',
        'created_at',
        'updated_at',
      ])

      // Export orders (with related data)
      const orders = ordersStore.orders.value || []
      const ordersCSV = arrayToCSV(
        orders.map((order) => ({
          id: order.id,
          buyer_id: order.buyer_id,
          buyer_first_name: order.buyer?.first_name || '',
          buyer_last_name: order.buyer?.last_name || '',
          buyer_email: order.buyer?.email || '',
          address_id: order.address_id || '',
          address_line1: order.buyer_address?.address_line1 || '',
          address_line2: order.buyer_address?.address_line2 || '',
          city: order.buyer_address?.city || '',
          state: order.buyer_address?.state || '',
          postal_code: order.buyer_address?.postal_code || '',
          country: order.buyer_address?.country || '',
          event_id: order.event_id,
          event_name: order.event?.name || '',
          event_year: order.event?.year || '',
          order_date: order.order_date,
          quantity: order.quantity,
          total_price: order.total_price,
          amount_paid: order.amount_paid,
          fee: order.fee || '',
          payment_method: order.payment_method || '',
          room_number: order.room_number || '',
          status: order.status,
          order_number: order.order_number || '',
          tracking_number: order.tracking_number || '',
          usps_zone: order.usps_zone || '',
          length: order.length || '',
          width: order.width || '',
          height: order.height || '',
          weight: order.weight || '',
          estimated_postage_cost: order.estimated_postage_cost || '',
          actual_postage_cost: order.actual_postage_cost || '',
          notes: order.notes || '',
          created_at: order.created_at,
          updated_at: order.updated_at,
        })),
        [
          'id',
          'buyer_id',
          'buyer_first_name',
          'buyer_last_name',
          'buyer_email',
          'address_id',
          'address_line1',
          'address_line2',
          'city',
          'state',
          'postal_code',
          'country',
          'event_id',
          'event_name',
          'event_year',
          'order_date',
          'quantity',
          'total_price',
          'amount_paid',
          'fee',
          'payment_method',
          'room_number',
          'status',
          'order_number',
          'tracking_number',
          'usps_zone',
          'length',
          'width',
          'height',
          'weight',
          'estimated_postage_cost',
          'actual_postage_cost',
          'notes',
          'created_at',
          'updated_at',
        ]
      )

      // Export shipping rates
      const shippingRates = shippingRatesStore.shippingRates.value || []
      const shippingRatesCSV = arrayToCSV(shippingRates, [
        'id',
        'quantity',
        'zone',
        'cost',
        'created_at',
        'updated_at',
      ])

      // Combine all CSV data
      const allData = [
        '=== BUYERS ===',
        buyersCSV,
        '',
        '=== EVENTS ===',
        eventsCSV,
        '',
        '=== ADDRESSES ===',
        addressesCSV,
        '',
        '=== ORDERS ===',
        ordersCSV,
        '',
        '=== SHIPPING_RATES ===',
        shippingRatesCSV,
      ].join('\n')

      // Download as single file
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5)
      downloadCSV(allData, `bandanas_data_export_${timestamp}.csv`)

      return {
        success: true,
        buyers: buyers.length,
        events: events.length,
        addresses: addresses.length,
        orders: orders.length,
        shippingRates: shippingRates.length,
      }
    } catch (error) {
      console.error('Export error:', error)
      throw error
    }
  }

  return {
    exportAllData,
  }
}

