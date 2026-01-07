# Bandanas Data Import Guide

## Data Import Strategy

You have:

- 270 buyers
- 151 orders
- 306 addresses (with duplicates)

## Recommended Import Order

### 1. Import Buyers First

```sql
-- Import buyers CSV/data
-- Make sure each buyer has a unique ID (UUID)
```

### 2. Import Addresses Second

```sql
-- Import addresses CSV/data
-- Each address MUST have a buyer_id that matches an existing buyer
-- Duplicates are okay at this stage - we'll clean them up
```

### 3. Import Orders Third

```sql
-- Import orders CSV/data
-- Each order MUST have:
--   - buyer_id (must exist in buyers table)
--   - event_id (must exist in events table)
--   - address_id (optional, but if provided, should belong to the buyer)
```

### 4. Clean Up Duplicates

Run the cleanup script:

```bash
docker exec -i potterybase-postgres-1 psql -U postgres -d local < scripts/fix_bandanas_duplicates.sql
```

Or apply the migration:

```bash
# The migration is already created at:
# nhost/migrations/default/1767537000000_fix_bandanas_address_duplicates/up.sql
```

## Important Notes

1. **Address Duplicates**: The cleanup script will:
   - Keep the oldest address for each duplicate group (same buyer + address details)
   - Update all orders to point to the kept address
   - Delete the duplicate addresses

2. **Order Address Validation**: The script ensures:
   - All addresses on orders belong to the order's buyer
   - If an address doesn't belong to the buyer, it sets address_id to NULL

3. **Data Integrity**: After cleanup:
   - Each unique address per buyer will appear only once
   - All orders will reference valid addresses (or NULL)
   - All order addresses will belong to the order's buyer

## CSV Import Format

### Buyers CSV should have:

- id (UUID) - optional, can be generated
- first_name (required)
- last_name (required)
- email (optional)

### Addresses CSV should have:

- id (UUID) - optional, can be generated
- buyer_id (UUID, required) - must match a buyer
- address_line1 (required)
- address_line2 (optional)
- city (required)
- state (optional)
- postal_code (required)
- country (optional, defaults to 'US')

### Orders CSV should have:

- id (UUID) - optional, can be generated
- buyer_id (UUID, required) - must match a buyer
- address_id (UUID, optional) - should match an address for this buyer
- event_id (UUID, required) - must match an event
- order_date (timestamp)
- quantity (integer, required)
- total_price (decimal, required)
- amount_paid (decimal, required)
- payment_method (text, optional)
- notes (text, optional)

## Running the Cleanup Script

Before running, you can preview what will be changed:

```sql
-- Preview duplicates
SELECT
  buyer_id,
  address_line1,
  city,
  postal_code,
  COUNT(*) as dup_count
FROM bandanas.buyer_addresses
GROUP BY buyer_id, address_line1, city, postal_code
HAVING COUNT(*) > 1;
```

Then run the cleanup script (it's wrapped in a transaction, so you can rollback if needed).
