import { ref } from 'vue'

/**
 * Composable for Mapbox Geocoding API
 * Requires MAPBOX_ACCESS_TOKEN environment variable
 */
export function useMapboxGeocoding() {
  const isLoading = ref(false)
  const error = ref(null)

  // Get API key from environment variable
  // In production, set this in your environment or use a .env file
  const accessToken =
    process.env.MAPBOX_ACCESS_TOKEN || import.meta.env.VITE_MAPBOX_ACCESS_TOKEN || ''

  /**
   * Search for addresses using Mapbox Geocoding API
   * @param {string} query - The search query (address, place, etc.)
   * @param {Object} options - Additional options (country, proximity, etc.)
   * @returns {Promise<Array>} Array of address suggestions
   */
  async function searchAddresses(query, options = {}) {
    if (!query || query.trim().length < 3) {
      return []
    }

    if (!accessToken) {
      console.warn(
        'Mapbox access token not found. Set MAPBOX_ACCESS_TOKEN or VITE_MAPBOX_ACCESS_TOKEN environment variable.'
      )
      return []
    }

    isLoading.value = true
    error.value = null

    try {
      const { country = 'US', proximity, limit = 5 } = options

      // Build the API URL
      const baseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places'
      const encodedQuery = encodeURIComponent(query)
      let url = `${baseUrl}/${encodedQuery}.json?access_token=${accessToken}&limit=${limit}`

      // Add country filter if provided
      if (country) {
        url += `&country=${country}`
      }

      // Add proximity if provided (lon,lat)
      if (proximity) {
        url += `&proximity=${proximity}`
      }

      // Add address types for better results
      url += '&types=address,poi'

      const response = await fetch(url)

      if (!response.ok) {
        throw new Error(`Mapbox API error: ${response.statusText}`)
      }

      const data = await response.json()

      // Transform Mapbox results to a simpler format
      return data.features.map((feature) => ({
        id: feature.id,
        fullAddress: feature.place_name,
        addressLine1: extractAddressLine1(feature),
        addressLine2: extractAddressLine2(feature),
        city: extractCity(feature),
        state: extractState(feature),
        postalCode: extractPostalCode(feature),
        country: extractCountry(feature),
        coordinates: feature.center, // [longitude, latitude]
        context: feature.context,
        raw: feature, // Keep raw data for reference
      }))
    } catch (err) {
      error.value = err.message
      console.error('Mapbox geocoding error:', err)
      return []
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Extract address line 1 from Mapbox feature
   */
  function extractAddressLine1(feature) {
    // Mapbox structure:
    // - feature.properties.address contains the house/building number (if available)
    // - feature.text contains the street name
    // - feature.place_name contains the full formatted address (e.g., "123 Main St, City, State ZIP")
    
    // First, try to get the full address from place_name (most reliable)
    const placeName = feature.place_name || ''
    if (placeName) {
      // Split by comma - first part should be the street address
      const parts = placeName.split(',')
      const streetAddress = parts[0]?.trim() || ''
      
      // If the street address contains a number, use it
      if (streetAddress && /\d/.test(streetAddress)) {
        return streetAddress
      }
    }
    
    // Fallback: combine address number and street name
    const addressNumber = feature.properties?.address || ''
    const streetName = feature.text || ''
    
    if (addressNumber && streetName) {
      return `${addressNumber} ${streetName}`
    }
    
    // If we only have street name, use it
    if (streetName) {
      return streetName
    }
    
    // Last resort: use first part of place_name or empty string
    return placeName.split(',')[0]?.trim() || ''
  }

  /**
   * Extract address line 2 (apt, suite, etc.) from Mapbox feature
   */
  function extractAddressLine2(feature) {
    // Mapbox doesn't typically provide line 2, but we can check properties
    return feature.properties?.address_extended || ''
  }

  /**
   * Extract city from Mapbox feature context
   */
  function extractCity(feature) {
    const place = feature.context?.find((ctx) => ctx.id.startsWith('place'))
    return place?.text || ''
  }

  /**
   * Extract state from Mapbox feature context
   */
  function extractState(feature) {
    const region = feature.context?.find((ctx) => ctx.id.startsWith('region'))
    return region?.short_code?.replace('US-', '') || region?.text || ''
  }

  /**
   * Extract postal code from Mapbox feature context
   */
  function extractPostalCode(feature) {
    const postcode = feature.context?.find((ctx) => ctx.id.startsWith('postcode'))
    return postcode?.text || ''
  }

  /**
   * Extract country from Mapbox feature context
   */
  function extractCountry(feature) {
    const country = feature.context?.find((ctx) => ctx.id.startsWith('country'))
    return country?.short_code || 'US'
  }

  return {
    isLoading,
    error,
    searchAddresses,
  }
}

