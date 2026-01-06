-- Fix duplicate addresses and ensure orders reference correct addresses
-- This script:
-- 1. Identifies duplicate addresses (same buyer + address details)
-- 2. Keeps the oldest address (minimum ID) and updates orders to point to it
-- 3. Deletes duplicate addresses
-- 4. Ensures all order addresses belong to the order's buyer

-- Step 1: Create a temporary table to track address duplicates and their canonical IDs
CREATE TEMP TABLE address_duplicates AS
WITH address_keys AS (
  SELECT 
    id,
    buyer_id,
    created_at,
    LOWER(TRIM(address_line1)) || '|' || 
    LOWER(TRIM(COALESCE(address_line2, ''))) || '|' ||
    LOWER(TRIM(city)) || '|' ||
    LOWER(TRIM(COALESCE(state, ''))) || '|' ||
    TRIM(postal_code) || '|' ||
    LOWER(TRIM(COALESCE(country, 'US'))) as address_key
  FROM bandanas.buyer_addresses
),
canonical_ids AS (
  SELECT 
    buyer_id,
    address_key,
    (array_agg(id ORDER BY created_at ASC))[1] as canonical_id
  FROM address_keys
  GROUP BY buyer_id, address_key
)
SELECT 
  ak.id as duplicate_id,
  ci.canonical_id
FROM address_keys ak
INNER JOIN canonical_ids ci ON
  ak.buyer_id = ci.buyer_id
  AND ak.address_key = ci.address_key
WHERE ak.id != ci.canonical_id;

-- Step 2: Update orders to point to canonical addresses (if they reference duplicates)
UPDATE bandanas.orders o
SET address_id = ad.canonical_id
FROM address_duplicates ad
WHERE o.address_id = ad.duplicate_id;

-- Step 3: Delete duplicate addresses
DELETE FROM bandanas.buyer_addresses
WHERE id IN (SELECT duplicate_id FROM address_duplicates);

-- Step 4: Fix orders where address doesn't belong to the buyer
-- Set address_id to NULL if the address doesn't belong to the order's buyer
UPDATE bandanas.orders o
SET address_id = NULL
WHERE o.address_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM bandanas.buyer_addresses ba
    WHERE ba.id = o.address_id
      AND ba.buyer_id = o.buyer_id
  );

-- Step 5: Clean up - drop temp table
DROP TABLE IF EXISTS address_duplicates;
