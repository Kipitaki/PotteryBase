-- Script to fix duplicate addresses and ensure data integrity
-- Run this AFTER importing your data
-- 
-- This script will:
-- 1. Remove duplicate addresses (keeping the oldest one for each buyer/address combination)
-- 2. Update orders to point to the canonical (kept) address
-- 3. Ensure all order addresses belong to the order's buyer
--
-- WARNING: This will DELETE duplicate addresses. Make a backup first!

BEGIN;

-- Step 1: Create a temporary table to track address duplicates and their canonical IDs
-- We keep the address with the minimum ID (oldest) for each duplicate group
CREATE TEMP TABLE address_duplicates AS
WITH address_keys AS (
  SELECT 
    id,
    buyer_id,
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
    MIN(id) as canonical_id
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

-- Show what will be changed (for review)
SELECT 
  'Duplicate addresses to be removed:' as info,
  COUNT(*) as count
FROM address_duplicates;

SELECT 
  'Orders that will be updated:' as info,
  COUNT(*) as count
FROM bandanas.orders o
WHERE o.address_id IN (SELECT duplicate_id FROM address_duplicates);

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

-- Show final counts
SELECT 
  'Final address count:' as info,
  COUNT(*) as count
FROM bandanas.buyer_addresses;

SELECT 
  'Orders with addresses:' as info,
  COUNT(*) as count
FROM bandanas.orders
WHERE address_id IS NOT NULL;

SELECT 
  'Orders with invalid addresses (should be 0):' as info,
  COUNT(*) as count
FROM bandanas.orders o
WHERE o.address_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM bandanas.buyer_addresses ba
    WHERE ba.id = o.address_id
      AND ba.buyer_id = o.buyer_id
  );

-- Step 5: Clean up - drop temp table
DROP TABLE IF EXISTS address_duplicates;

COMMIT;
