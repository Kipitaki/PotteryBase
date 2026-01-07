-- Export ALL Bandanas Data in One Query
-- Run this in your LOCAL Hasura Console SQL editor
-- This generates a single result set with all INSERT statements
-- Copy all results and save to a file for import

-- This query combines all exports into one result set
SELECT 
  CASE 
    WHEN table_name = 'buyers' THEN
      'INSERT INTO bandanas.buyers (id, first_name, last_name, email, created_at, updated_at) VALUES (' ||
      quote_literal(id::text) || ', ' ||
      quote_literal(first_name) || ', ' ||
      quote_literal(last_name) || ', ' ||
      COALESCE(quote_literal(email), 'NULL') || ', ' ||
      quote_literal(created_at::text) || ', ' ||
      quote_literal(updated_at::text) || 
      ');'
    WHEN table_name = 'events' THEN
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
      ');'
    WHEN table_name = 'buyer_addresses' THEN
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
      ');'
    WHEN table_name = 'orders' THEN
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
      ');'
    WHEN table_name = 'shipping_rates' THEN
      'INSERT INTO bandanas.shipping_rates (id, quantity, zone, cost, created_at, updated_at) VALUES (' ||
      quote_literal(id::text) || ', ' ||
      quantity || ', ' ||
      zone || ', ' ||
      cost || ', ' ||
      quote_literal(created_at::text) || ', ' ||
      quote_literal(updated_at::text) ||
      ');'
  END AS sql_statement,
  table_name,
  sort_order
FROM (
  -- Buyers (order 1)
  SELECT 'buyers'::text AS table_name, id, first_name, last_name, email, created_at, updated_at,
    NULL::text AS name, NULL::integer AS year, NULL::numeric AS price_single, NULL::numeric AS price_multi,
    NULL::boolean AS active, NULL::numeric AS bandana_cost, NULL::numeric AS freight,
    NULL::numeric AS fee_tax_transaction_fees, NULL::integer AS total_qty, NULL::text AS image_url,
    NULL::numeric AS freight_out, NULL::uuid AS buyer_id, NULL::text AS address_line1,
    NULL::text AS address_line2, NULL::text AS city, NULL::text AS state, NULL::text AS postal_code,
    NULL::text AS country, NULL::text AS original_address_id, NULL::uuid AS address_id,
    NULL::uuid AS event_id, NULL::timestamptz AS order_date, NULL::integer AS quantity,
    NULL::numeric AS total_price, NULL::numeric AS amount_paid, NULL::text AS payment_method,
    NULL::text AS notes, NULL::numeric AS fee, NULL::text AS room_number, NULL::text AS status,
    NULL::text AS order_number, NULL::text AS tracking_number, NULL::integer AS usps_zone,
    NULL::numeric AS length, NULL::numeric AS width, NULL::numeric AS height, NULL::numeric AS weight,
    NULL::numeric AS estimated_postage_cost, NULL::numeric AS actual_postage_cost,
    NULL::integer AS zone, NULL::numeric AS cost,
    1 AS sort_order
  FROM bandanas.buyers
  
  UNION ALL
  
  -- Events (order 2)
  SELECT 'events'::text, id, NULL, NULL, NULL, created_at, updated_at,
    name, year, price_single, price_multi, active, bandana_cost, freight,
    fee_tax_transaction_fees, total_qty, image_url, freight_out,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    2
  FROM bandanas.events
  
  UNION ALL
  
  -- Buyer addresses (order 3)
  SELECT 'buyer_addresses'::text, id, NULL, NULL, NULL, created_at, updated_at,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    buyer_id, address_line1, address_line2, city, state, postal_code, country, original_address_id,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    3
  FROM bandanas.buyer_addresses
  
  UNION ALL
  
  -- Orders (order 4)
  SELECT 'orders'::text, id, NULL, NULL, NULL, created_at, updated_at,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    buyer_id, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    address_id, event_id, order_date, quantity, total_price, amount_paid, payment_method, notes,
    fee, room_number, status, order_number, tracking_number, usps_zone,
    length, width, height, weight, estimated_postage_cost, actual_postage_cost, NULL, NULL,
    4
  FROM bandanas.orders
  
  UNION ALL
  
  -- Shipping rates (order 5)
  SELECT 'shipping_rates'::text, id, NULL, NULL, NULL, created_at, updated_at,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    quantity, zone, cost,
    5
  FROM bandanas.shipping_rates
) AS all_data
ORDER BY sort_order, created_at;

