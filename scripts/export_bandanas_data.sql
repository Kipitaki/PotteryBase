-- Export Bandanas Data Script
-- Run this in your LOCAL Hasura Console SQL editor
-- This will generate INSERT statements for all bandanas data
-- Copy the output and save it to a file, or use the shell script version

-- Export buyers (must be first due to foreign key constraints)
SELECT 
  'INSERT INTO bandanas.buyers (id, first_name, last_name, email, created_at, updated_at) VALUES (' ||
  quote_literal(id::text) || ', ' ||
  quote_literal(first_name) || ', ' ||
  quote_literal(last_name) || ', ' ||
  COALESCE(quote_literal(email), 'NULL') || ', ' ||
  quote_literal(created_at::text) || ', ' ||
  quote_literal(updated_at::text) || 
  ');' AS sql_statement
FROM bandanas.buyers
ORDER BY created_at;

-- Export events (must be before orders)
SELECT 
  'INSERT INTO bandanas.events (id, name, year, price_single, price_multi, active, created_at, updated_at, bandana_cost, freight, fee_tax_transaction_fees, total_qty, image_url, freight_out) VALUES (' ||
  quote_literal(id::text) || ', ' ||
  quote_literal(name) || ', ' ||
  year || ', ' ||
  price_single || ', ' ||
  price_multi || ', ' ||
  active || ', ' ||
  quote_literal(created_at::text) || ', ' ||
  quote_literal(updated_at::text) || ', ' ||
  COALESCE(bandana_cost::text, 'NULL') || ', ' ||
  COALESCE(freight::text, 'NULL') || ', ' ||
  COALESCE(fee_tax_transaction_fees::text, 'NULL') || ', ' ||
  COALESCE(total_qty::text, 'NULL') || ', ' ||
  COALESCE(quote_literal(image_url), 'NULL') || ', ' ||
  COALESCE(freight_out::text, 'NULL') ||
  ');' AS sql_statement
FROM bandanas.events
ORDER BY created_at;

-- Export buyer_addresses (must be before orders)
SELECT 
  'INSERT INTO bandanas.buyer_addresses (id, buyer_id, address_line1, address_line2, city, state, postal_code, country, created_at, updated_at, original_address_id) VALUES (' ||
  quote_literal(id::text) || ', ' ||
  quote_literal(buyer_id::text) || ', ' ||
  quote_literal(address_line1) || ', ' ||
  COALESCE(quote_literal(address_line2), 'NULL') || ', ' ||
  quote_literal(city) || ', ' ||
  COALESCE(quote_literal(state), 'NULL') || ', ' ||
  quote_literal(postal_code) || ', ' ||
  quote_literal(country) || ', ' ||
  quote_literal(created_at::text) || ', ' ||
  quote_literal(updated_at::text) || ', ' ||
  COALESCE(quote_literal(original_address_id), 'NULL') ||
  ');' AS sql_statement
FROM bandanas.buyer_addresses
ORDER BY created_at;

-- Export orders (depends on buyers, addresses, and events)
SELECT 
  'INSERT INTO bandanas.orders (id, buyer_id, address_id, event_id, order_date, quantity, total_price, amount_paid, payment_method, notes, created_at, updated_at, fee, room_number, status, order_number, tracking_number, usps_zone, length, width, height, weight, estimated_postage_cost, actual_postage_cost) VALUES (' ||
  quote_literal(id::text) || ', ' ||
  quote_literal(buyer_id::text) || ', ' ||
  COALESCE(quote_literal(address_id::text), 'NULL') || ', ' ||
  quote_literal(event_id::text) || ', ' ||
  quote_literal(order_date::text) || ', ' ||
  quantity || ', ' ||
  total_price || ', ' ||
  amount_paid || ', ' ||
  COALESCE(quote_literal(payment_method), 'NULL') || ', ' ||
  COALESCE(quote_literal(notes), 'NULL') || ', ' ||
  quote_literal(created_at::text) || ', ' ||
  quote_literal(updated_at::text) || ', ' ||
  COALESCE(fee::text, 'NULL') || ', ' ||
  COALESCE(quote_literal(room_number), 'NULL') || ', ' ||
  quote_literal(status) || ', ' ||
  COALESCE(quote_literal(order_number), 'NULL') || ', ' ||
  COALESCE(quote_literal(tracking_number), 'NULL') || ', ' ||
  COALESCE(usps_zone::text, 'NULL') || ', ' ||
  COALESCE(length::text, 'NULL') || ', ' ||
  COALESCE(width::text, 'NULL') || ', ' ||
  COALESCE(height::text, 'NULL') || ', ' ||
  COALESCE(weight::text, 'NULL') || ', ' ||
  COALESCE(estimated_postage_cost::text, 'NULL') || ', ' ||
  COALESCE(actual_postage_cost::text, 'NULL') ||
  ');' AS sql_statement
FROM bandanas.orders
ORDER BY created_at;

-- Export shipping_rates
SELECT 
  'INSERT INTO bandanas.shipping_rates (id, quantity, zone, cost, created_at, updated_at) VALUES (' ||
  quote_literal(id::text) || ', ' ||
  quantity || ', ' ||
  zone || ', ' ||
  cost || ', ' ||
  quote_literal(created_at::text) || ', ' ||
  quote_literal(updated_at::text) ||
  ');' AS sql_statement
FROM bandanas.shipping_rates
ORDER BY quantity, zone;

