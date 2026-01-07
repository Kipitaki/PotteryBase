/**
 * Package dimensions and weight mapping based on quantity
 * Based on bandana order quantities
 */
export const PACKAGE_DIMENSIONS = {
  1: {
    length: 4,
    width: 6,
    height: 0.5,
    weight: 3, // ounces
  },
  2: {
    length: 4,
    width: 6,
    height: 0.5,
    weight: 4, // ounces
  },
  3: {
    length: 4,
    width: 6,
    height: 0.5,
    weight: 6.2, // ounces
  },
  4: {
    length: 7,
    width: 6,
    height: 0.5,
    weight: 8, // ounces
  },
}

/**
 * Get package dimensions and weight for a given quantity
 * @param {number} quantity - Number of items in the order
 * @returns {Object|null} Object with length, width, height, weight or null if quantity not supported
 */
export function getPackageDimensions(quantity) {
  if (quantity <= 0) {
    return null
  }
  
  // For quantities > 4, calculate based on the pattern
  // We'll use qty 4 as base and add dimensions/weight proportionally
  if (quantity > 4) {
    const baseQty = 4
    const base = PACKAGE_DIMENSIONS[baseQty]
    const multiplier = quantity / baseQty
    
    // For larger quantities, increase length proportionally
    // Weight increases proportionally, height may stay the same or increase slightly
    return {
      length: Math.ceil(base.length * multiplier),
      width: base.width,
      height: base.height,
      weight: base.weight * multiplier,
    }
  }
  
  return PACKAGE_DIMENSIONS[quantity] || null
}

