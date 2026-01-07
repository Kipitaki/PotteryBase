import { useBuyersStore } from 'stores/bandanas/buyers'
import { useBuyerAddressesStore } from 'stores/bandanas/buyerAddresses'
import { useEventsStore } from 'stores/bandanas/events'
import { useOrdersStore } from 'stores/bandanas/orders'
import { useShippingRatesStore } from 'stores/bandanas/shippingRates'

// Parse CSV text into sections
function parseCSVSections(text) {
  const sections = {
    buyers: [],
    events: [],
    addresses: [],
    orders: [],
    shipping_rates: [],
  }

  const lines = text.split('\n')
  let currentSection = null
  let headers = null
  let sectionLines = []

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()

    // Check for section headers
    if (line.startsWith('=== ')) {
      // Save previous section
      if (currentSection && headers && sectionLines.length > 0) {
        sections[currentSection] = parseCSVSection(headers, sectionLines)
      }

      // Start new section
      if (line.includes('BUYERS')) {
        currentSection = 'buyers'
      } else if (line.includes('EVENTS')) {
        currentSection = 'events'
      } else if (line.includes('ADDRESSES')) {
        currentSection = 'addresses'
      } else if (line.includes('ORDERS')) {
        currentSection = 'orders'
      } else if (line.includes('SHIPPING_RATES')) {
        currentSection = 'shipping_rates'
      } else {
        currentSection = null
      }
      headers = null
      sectionLines = []
      continue
    }

    // Skip empty lines
    if (!line) continue

    // Parse header row
    if (!headers && currentSection) {
      headers = parseCSVLine(line)
      continue
    }

    // Parse data rows
    if (headers && currentSection) {
      sectionLines.push(line)
    }
  }

  // Save last section
  if (currentSection && headers && sectionLines.length > 0) {
    sections[currentSection] = parseCSVSection(headers, sectionLines)
  }

  return sections
}

// Parse a single CSV line (handles quoted values)
function parseCSVLine(line) {
  const result = []
  let current = ''
  let inQuotes = false

  for (let i = 0; i < line.length; i++) {
    const char = line[i]

    if (char === '"') {
      if (inQuotes && line[i + 1] === '"') {
        // Escaped quote
        current += '"'
        i++
      } else {
        // Toggle quote state
        inQuotes = !inQuotes
      }
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

// Parse a CSV section into objects
function parseCSVSection(headers, lines) {
  const rows = []
  for (const line of lines) {
    const values = parseCSVLine(line)
    if (values.length === 0) continue

    const row = {}
    headers.forEach((header, index) => {
      const value = values[index] || ''
      // Remove surrounding quotes
      const cleanValue = value.replace(/^"|"$/g, '')
      row[header] = cleanValue === '' ? null : cleanValue
    })
    rows.push(row)
  }
  return rows
}

export function useBandanasDataImport() {
  const buyersStore = useBuyersStore()
  const addressesStore = useBuyerAddressesStore()
  const eventsStore = useEventsStore()
  const ordersStore = useOrdersStore()
  const shippingRatesStore = useShippingRatesStore()

  async function importAllData(csvText) {
    const results = {
      buyers: { success: 0, failed: 0, errors: [] },
      events: { success: 0, failed: 0, errors: [] },
      addresses: { success: 0, failed: 0, errors: [] },
      orders: { success: 0, failed: 0, errors: [] },
      shipping_rates: { success: 0, failed: 0, errors: [] },
    }

    try {
      // Parse CSV sections
      const sections = parseCSVSections(csvText)

      // Step 1: Import buyers
      if (sections.buyers.length > 0) {
        await buyersStore.refetch()
        const existingBuyers = buyersStore.buyers.value || []

        for (let i = 0; i < sections.buyers.length; i++) {
          const row = sections.buyers[i]
          try {
            // Check if buyer exists by first_name and last_name
            const existing = existingBuyers.find(
              (b) =>
                b.first_name?.toLowerCase().trim() === row.first_name?.toLowerCase().trim() &&
                b.last_name?.toLowerCase().trim() === row.last_name?.toLowerCase().trim()
            )

            if (existing) {
              // Update existing buyer
              await buyersStore.updateBuyer(existing.id, {
                email: row.email || existing.email,
                original_buyer_id: row.original_buyer_id || existing.original_buyer_id,
              })
              results.buyers.success++
            } else {
              // Create new buyer
              await buyersStore.createBuyer({
                first_name: row.first_name,
                last_name: row.last_name,
                email: row.email || null,
                original_buyer_id: row.original_buyer_id || null,
              })
              results.buyers.success++
            }
          } catch (error) {
            results.buyers.failed++
            results.buyers.errors.push({
              row: i + 1,
              data: row,
              error: error.message || 'Unknown error',
            })
          }
        }
        await buyersStore.refetch()
      }

      // Step 2: Import events
      if (sections.events.length > 0) {
        await eventsStore.refetch()
        const existingEvents = eventsStore.events.value || []

        for (let i = 0; i < sections.events.length; i++) {
          const row = sections.events[i]
          try {
            // Check if event exists by name and year
            const existing = existingEvents.find(
              (e) =>
                e.name?.toLowerCase().trim() === row.name?.toLowerCase().trim() &&
                e.year === parseInt(row.year)
            )

            if (existing) {
              // Update existing event
              await eventsStore.updateEvent(existing.id, {
                price_single: parseFloat(row.price_single) || 0,
                price_multi: parseFloat(row.price_multi) || 0,
                active: row.active === 'true' || row.active === true,
                bandana_cost: row.bandana_cost ? parseFloat(row.bandana_cost) : null,
                freight: row.freight ? parseFloat(row.freight) : null,
                fee_tax_transaction_fees: row.fee_tax_transaction_fees
                  ? parseFloat(row.fee_tax_transaction_fees)
                  : null,
                total_qty: row.total_qty ? parseInt(row.total_qty) : null,
                image_url: row.image_url || null,
                freight_out: row.freight_out ? parseFloat(row.freight_out) : null,
              })
              results.events.success++
            } else {
              // Create new event
              await eventsStore.createEvent({
                name: row.name,
                year: parseInt(row.year),
                price_single: parseFloat(row.price_single) || 0,
                price_multi: parseFloat(row.price_multi) || 0,
                active: row.active === 'true' || row.active === true,
                bandana_cost: row.bandana_cost ? parseFloat(row.bandana_cost) : null,
                freight: row.freight ? parseFloat(row.freight) : null,
                fee_tax_transaction_fees: row.fee_tax_transaction_fees
                  ? parseFloat(row.fee_tax_transaction_fees)
                  : null,
                total_qty: row.total_qty ? parseInt(row.total_qty) : null,
                image_url: row.image_url || null,
                freight_out: row.freight_out ? parseFloat(row.freight_out) : null,
              })
              results.events.success++
            }
          } catch (error) {
            results.events.failed++
            results.events.errors.push({
              row: i + 1,
              data: row,
              error: error.message || 'Unknown error',
            })
          }
        }
        await eventsStore.refetch()
      }

      // Step 3: Import addresses
      if (sections.addresses.length > 0) {
        await addressesStore.refetch()
        await buyersStore.refetch()
        const existingAddresses = addressesStore.buyerAddresses.value || []

        for (let i = 0; i < sections.addresses.length; i++) {
          const row = sections.addresses[i]
          try {
            // Find buyer by ID or by first_name/last_name
            let buyerId = row.buyer_id
            if (!buyerId) {
              // Try to find buyer by name (if provided in orders section)
              continue // Skip if no buyer_id
            }

            // Check if address exists
            const existing = existingAddresses.find(
              (a) =>
                a.buyer_id === buyerId &&
                a.address_line1?.toLowerCase().trim() ===
                  row.address_line1?.toLowerCase().trim() &&
                a.city?.toLowerCase().trim() === row.city?.toLowerCase().trim() &&
                a.state?.toLowerCase().trim() === row.state?.toLowerCase().trim() &&
                a.postal_code?.trim() === row.postal_code?.trim()
            )

            if (existing) {
              // Update existing address
              await addressesStore.updateBuyerAddress(existing.id, {
                address_line2: row.address_line2 || null,
                country: row.country || 'US',
                original_address_id: row.original_address_id || null,
              })
              results.addresses.success++
            } else {
              // Create new address
              await addressesStore.createBuyerAddress({
                buyer_id: buyerId,
                address_line1: row.address_line1,
                address_line2: row.address_line2 || null,
                city: row.city,
                state: row.state || null,
                postal_code: row.postal_code,
                country: row.country || 'US',
                original_address_id: row.original_address_id || null,
              })
              results.addresses.success++
            }
          } catch (error) {
            results.addresses.failed++
            results.addresses.errors.push({
              row: i + 1,
              data: row,
              error: error.message || 'Unknown error',
            })
          }
        }
        await addressesStore.refetch()
      }

      // Step 4: Import orders
      if (sections.orders.length > 0) {
        await ordersStore.refetch()
        await buyersStore.refetch()
        await addressesStore.refetch()
        await eventsStore.refetch()
        const allBuyers = buyersStore.buyers.value || []
        const allAddresses = addressesStore.buyerAddresses.value || []
        const allEvents = eventsStore.events.value || []

        for (let i = 0; i < sections.orders.length; i++) {
          const row = sections.orders[i]
          try {
            // Find buyer by ID or by name
            let buyerId = row.buyer_id
            if (!buyerId && row.buyer_first_name && row.buyer_last_name) {
              const buyer = allBuyers.find(
                (b) =>
                  b.first_name?.toLowerCase().trim() ===
                    row.buyer_first_name?.toLowerCase().trim() &&
                  b.last_name?.toLowerCase().trim() === row.buyer_last_name?.toLowerCase().trim()
              )
              if (buyer) buyerId = buyer.id
            }
            if (!buyerId) {
              throw new Error('Buyer not found')
            }

            // Find event by ID or by name/year
            let eventId = row.event_id
            if (!eventId && row.event_name && row.event_year) {
              const event = allEvents.find(
                (e) =>
                  e.name?.toLowerCase().trim() === row.event_name?.toLowerCase().trim() &&
                  e.year === parseInt(row.event_year)
              )
              if (event) eventId = event.id
            }
            if (!eventId) {
              throw new Error('Event not found')
            }

            // Find address by ID or by details
            let addressId = row.address_id || null
            if (!addressId && row.address_line1 && row.city && row.postal_code) {
              const address = allAddresses.find(
                (a) =>
                  a.buyer_id === buyerId &&
                  a.address_line1?.toLowerCase().trim() ===
                    row.address_line1?.toLowerCase().trim() &&
                  a.city?.toLowerCase().trim() === row.city?.toLowerCase().trim() &&
                  a.postal_code?.trim() === row.postal_code?.trim()
              )
              if (address) addressId = address.id
            }

            // Check if order exists by buyer_id and event_id (and optionally order_number)
            const existingOrder = row.order_number
              ? ordersStore.orders.value.find((o) => o.order_number === row.order_number)
              : null

            const orderData = {
              buyer_id: buyerId,
              address_id: addressId,
              event_id: eventId,
              order_date: row.order_date || new Date().toISOString(),
              quantity: parseInt(row.quantity) || 1,
              total_price: parseFloat(row.total_price) || 0,
              amount_paid: parseFloat(row.amount_paid) || 0,
              fee: row.fee ? parseFloat(row.fee) : null,
              payment_method: row.payment_method || null,
              room_number: row.room_number || null,
              status: row.status || 'Ordered',
              order_number: row.order_number || null,
              tracking_number: row.tracking_number || null,
              usps_zone: row.usps_zone ? parseInt(row.usps_zone) : null,
              length: row.length ? parseFloat(row.length) : null,
              width: row.width ? parseFloat(row.width) : null,
              height: row.height ? parseFloat(row.height) : null,
              weight: row.weight ? parseFloat(row.weight) : null,
              estimated_postage_cost: row.estimated_postage_cost
                ? parseFloat(row.estimated_postage_cost)
                : null,
              actual_postage_cost: row.actual_postage_cost
                ? parseFloat(row.actual_postage_cost)
                : null,
              notes: row.notes || null,
            }

            if (existingOrder) {
              // Update existing order
              await ordersStore.updateOrder(existingOrder.id, orderData)
              results.orders.success++
            } else {
              // Create new order
              await ordersStore.createOrder(orderData)
              results.orders.success++
            }
          } catch (error) {
            results.orders.failed++
            results.orders.errors.push({
              row: i + 1,
              data: row,
              error: error.message || 'Unknown error',
            })
          }
        }
        await ordersStore.refetch()
      }

      // Step 5: Import shipping rates
      if (sections.shipping_rates.length > 0) {
        await shippingRatesStore.refetch()
        const existingRates = shippingRatesStore.shippingRates.value || []

        for (let i = 0; i < sections.shipping_rates.length; i++) {
          const row = sections.shipping_rates[i]
          try {
            // Check if rate exists by quantity and zone
            const existing = existingRates.find(
              (r) =>
                r.quantity === parseInt(row.quantity) && r.zone === parseInt(row.zone)
            )

            if (existing) {
              // Update existing rate
              await shippingRatesStore.updateShippingRate(existing.id, {
                cost: parseFloat(row.cost) || 0,
              })
              results.shipping_rates.success++
            } else {
              // Create new rate
              await shippingRatesStore.createShippingRate({
                quantity: parseInt(row.quantity) || 1,
                zone: parseInt(row.zone) || 1,
                cost: parseFloat(row.cost) || 0,
              })
              results.shipping_rates.success++
            }
          } catch (error) {
            results.shipping_rates.failed++
            results.shipping_rates.errors.push({
              row: i + 1,
              data: row,
              error: error.message || 'Unknown error',
            })
          }
        }
        await shippingRatesStore.refetch()
      }

      return results
    } catch (error) {
      console.error('Import error:', error)
      throw error
    }
  }

  return {
    importAllData,
  }
}

