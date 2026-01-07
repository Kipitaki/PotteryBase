-- Diagnostic script to check if bandanas tables exist
-- Run this in your Hasura Console SQL tab or directly against the database

-- 1. Check if the bandanas schema exists
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name = 'bandanas';

-- 2. Check if tables exist in bandanas schema
SELECT 
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'bandanas'
ORDER BY table_name;

-- 3. Check if tables exist anywhere (in case they're in wrong schema)
SELECT 
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_name IN ('buyers', 'buyer_addresses', 'events', 'orders', 'shipping_rates')
ORDER BY table_schema, table_name;

-- 4. Check permissions on bandanas schema
SELECT 
    nspname as schema_name,
    nspacl as permissions
FROM pg_namespace
WHERE nspname = 'bandanas';

-- 5. Grant permissions if needed (run if schema exists but Hasura can't see it)
-- Uncomment and run if needed:
-- GRANT USAGE ON SCHEMA bandanas TO postgres;
-- GRANT ALL ON ALL TABLES IN SCHEMA bandanas TO postgres;
-- GRANT ALL ON ALL SEQUENCES IN SCHEMA bandanas TO postgres;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA bandanas GRANT ALL ON TABLES TO postgres;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA bandanas GRANT ALL ON SEQUENCES TO postgres;
