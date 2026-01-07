-- Import Bandanas Data Script
-- Run this in your REMOTE Hasura Console SQL editor
-- Paste the INSERT statements generated from export_bandanas_data.sql
-- 
-- IMPORTANT: This script includes ON CONFLICT handling to avoid duplicates
-- If you want to replace existing data, uncomment the DELETE statements below

-- Optional: Clear existing data (uncomment if you want to replace everything)
-- DELETE FROM bandanas.orders;
-- DELETE FROM bandanas.buyer_addresses;
-- DELETE FROM bandanas.shipping_rates;
-- DELETE FROM bandanas.events;
-- DELETE FROM bandanas.buyers;

-- Paste your INSERT statements here, or use the shell script version
-- The INSERT statements should be in this order:
-- 1. buyers
-- 2. events
-- 3. buyer_addresses
-- 4. orders
-- 5. shipping_rates

-- Example format (replace with your actual data):
/*
INSERT INTO bandanas.buyers (id, first_name, last_name, email, created_at, updated_at) 
VALUES ('...', 'John', 'Doe', 'john@example.com', '2024-01-01', '2024-01-01')
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = EXCLUDED.email,
  updated_at = EXCLUDED.updated_at;
*/

-- Note: If your INSERT statements don't have ON CONFLICT, you can wrap them like this:
-- INSERT INTO bandanas.buyers (...) VALUES (...) ON CONFLICT (id) DO NOTHING;

