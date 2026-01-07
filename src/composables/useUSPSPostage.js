import { ref } from 'vue'

const ORIGIN_ZIP = '32207'

/**
 * Calculate USPS postage cost based on package dimensions, weight, and zone
 * Uses USPS RateV4 API if credentials are available
 * 
 * @see https://www.usps.com/business/web-tools-apis/rate-calculator-api.htm
 */
export function useUSPSPostage() {
  const isLoading = ref(false)
  const error = ref(null)

  /**
   * Calculate postage cost using USPS RateV4 API
   * 
   * @param {string} destinationZip - Destination zip code (5 digits)
   * @param {number} length - Package length in inches
   * @param {number} width - Package width in inches
   * @param {number} height - Package height in inches
   * @param {number} weightOz - Package weight in ounces
   * @param {string} service - Mail service type (default: 'PRIORITY')
   * @returns {Promise<number|null>} Postage cost in USD or null if unable to calculate
   */
  async function calculatePostage(destinationZip, length, width, height, weightOz, service = 'PRIORITY') {
    if (!destinationZip || !length || !width || !height || !weightOz) {
      return null
    }

    // Extract 5-digit zip code
    const zip = destinationZip.toString().trim().substring(0, 5)
    if (!/^\d{5}$/.test(zip)) {
      error.value = 'Invalid zip code format'
      return null
    }

    isLoading.value = true
    error.value = null

    try {
      // Check if USPS API credentials are configured
      const uspsUserId = process.env.USPS_USER_ID || import.meta.env.VITE_USPS_USER_ID
      
      if (uspsUserId) {
        // Use USPS API if credentials are available
        return await calculatePostageViaAPI(uspsUserId, zip, length, width, height, weightOz, service)
      } else {
        // Fallback to estimation based on zone and weight
        console.warn('USPS User ID not configured. Using estimation. Set VITE_USPS_USER_ID to use USPS API.')
        return null // Can't estimate accurately without zone, so return null
      }
    } catch (err) {
      error.value = err.message
      console.error('USPS postage calculation error:', err)
      return null
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Calculate postage using USPS RateV4 API
   * Requires USPS Web Tools account and User ID
   */
  async function calculatePostageViaAPI(uspsUserId, destinationZip, length, width, height, weightOz, service) {
    try {
      // Convert weight to pounds and ounces
      const pounds = Math.floor(weightOz / 16)
      const ounces = weightOz % 16

      // Build XML request for USPS RateV4 API
      const xmlRequest = `
        <RateV4Request USERID="${uspsUserId}">
          <Revision>2</Revision>
          <Package ID="1ST">
            <Service>${service}</Service>
            <ZipOrigination>${ORIGIN_ZIP}</ZipOrigination>
            <ZipDestination>${destinationZip}</ZipDestination>
            <Pounds>${pounds}</Pounds>
            <Ounces>${ounces}</Ounces>
            <Container>VARIABLE</Container>
            <Width>${width}</Width>
            <Length>${length}</Length>
            <Height>${height}</Height>
            <Girth></Girth>
          </Package>
        </RateV4Request>
      `.trim()

      const encodedXml = encodeURIComponent(xmlRequest)
      const url = `https://secure.shippingapis.com/ShippingAPI.dll?API=RateV4&XML=${encodedXml}`

      const response = await fetch(url)
      if (!response.ok) {
        throw new Error(`USPS API error: ${response.statusText}`)
      }

      const text = await response.text()
      
      // Parse XML response
      const parser = new DOMParser()
      const xmlDoc = parser.parseFromString(text, 'text/xml')
      
      // Check for errors
      const errorElement = xmlDoc.querySelector('Error')
      if (errorElement) {
        const errorDescription = errorElement.querySelector('Description')?.textContent || 'Unknown error'
        throw new Error(`USPS API error: ${errorDescription}`)
      }

      // Extract rate from response
      const rateElement = xmlDoc.querySelector('Rate')
      if (rateElement) {
        const rate = parseFloat(rateElement.textContent)
        if (!isNaN(rate) && rate > 0) {
          return rate
        }
      }

      throw new Error('Rate not found in USPS API response')
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  return {
    isLoading,
    error,
    calculatePostage,
    ORIGIN_ZIP,
  }
}

