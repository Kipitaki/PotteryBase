import { ref } from 'vue'

const ORIGIN_ZIP = '32207'

/**
 * Calculate USPS shipping zone based on destination zip code
 * Shipping from origin zip 32207
 * 
 * Note: This function can be extended to use the USPS RateV4 API
 * which requires a USPS Web Tools account. See:
 * https://www.usps.com/business/web-tools-apis/rate-calculator-api.htm
 * 
 * For now, this uses a basic distance-based calculation as an approximation.
 * For accurate zones, integrate the USPS API with your USPS User ID.
 */
export function useUSPSZone() {
  const isLoading = ref(false)
  const error = ref(null)

  /**
   * Calculate zone based on zip code distance
   * This is a simplified approximation. For accurate zones, use USPS API.
   * 
   * @param {string} destinationZip - Destination zip code (5 digits)
   * @returns {Promise<number|null>} Zone number (1-9) or null if unable to calculate
   */
  async function calculateZone(destinationZip) {
    if (!destinationZip) {
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
        return await calculateZoneViaAPI(uspsUserId, zip)
      } else {
        // Fallback to basic approximation (can be improved with zone lookup tables)
        console.warn('USPS User ID not configured. Using approximation. Set VITE_USPS_USER_ID to use USPS API.')
        return calculateZoneApproximation(zip)
      }
    } catch (err) {
      error.value = err.message
      console.error('USPS zone calculation error:', err)
      return null
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Calculate zone using USPS RateV4 API
   * Requires USPS Web Tools account and User ID
   */
  async function calculateZoneViaAPI(uspsUserId, destinationZip) {
    try {
      // Build XML request for USPS RateV4 API
      const xmlRequest = `
        <RateV4Request USERID="${uspsUserId}">
          <Revision>2</Revision>
          <Package ID="1ST">
            <Service>PRIORITY</Service>
            <ZipOrigination>${ORIGIN_ZIP}</ZipOrigination>
            <ZipDestination>${destinationZip}</ZipDestination>
            <Pounds>0</Pounds>
            <Ounces>10</Ounces>
            <Container>VARIABLE</Container>
            <Width></Width>
            <Length></Length>
            <Height></Height>
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

      // Extract zone from response
      const zoneElement = xmlDoc.querySelector('Zone')
      if (zoneElement) {
        const zone = parseInt(zoneElement.textContent, 10)
        if (zone >= 1 && zone <= 9) {
          return zone
        }
      }

      throw new Error('Zone not found in USPS API response')
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  /**
   * Basic approximation of zone based on zip code prefix
   * This is a simplified approximation and may not be accurate.
   * For production use, integrate with USPS API or use a zone lookup table.
   */
  function calculateZoneApproximation(destinationZip) {
    // This is a very basic approximation
    // USPS zones are complex and based on their internal zone charts
    // For accurate zones, use the USPS API or a zone lookup database
    
    const originPrefix = parseInt(ORIGIN_ZIP.substring(0, 3), 10)
    const destPrefix = parseInt(destinationZip.substring(0, 3), 10)
    const prefixDiff = Math.abs(originPrefix - destPrefix)

    // Very rough approximation based on zip prefix difference
    // Zone 1: Local area
    // Zone 2-3: Regional
    // Zone 4-5: Cross-country
    // Zone 6-8: Far distances
    // Zone 9: Farthest (Alaska/Hawaii/territories)
    
    if (prefixDiff === 0) {
      return 1 // Same area
    } else if (prefixDiff < 50) {
      return 2 // Nearby
    } else if (prefixDiff < 150) {
      return 3 // Regional
    } else if (prefixDiff < 300) {
      return 4 // Mid-distance
    } else if (prefixDiff < 500) {
      return 5 // Cross-country
    } else if (prefixDiff < 700) {
      return 6 // Far
    } else if (prefixDiff < 900) {
      return 7 // Very far
    } else {
      return 8 // Farthest continental
    }
  }

  return {
    isLoading,
    error,
    calculateZone,
    ORIGIN_ZIP,
  }
}

