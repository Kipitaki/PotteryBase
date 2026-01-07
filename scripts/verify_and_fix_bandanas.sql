-- Step 1: Verify current state - Run this first
SELECT 'Checking for bandanas schema...' as status;
SELECT EXISTS(
    SELECT 1 FROM information_schema.schemata WHERE schema_name = 'bandanas'
) as bandanas_schema_exists;

SELECT 'Checking for bandanas tables...' as status;
SELECT 
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_name IN ('buyers', 'buyer_addresses', 'events', 'orders', 'shipping_rates')
ORDER BY table_schema, table_name;

-- Step 2: If schema doesn't exist, create it and grant permissions
CREATE SCHEMA IF NOT EXISTS bandanas;

-- Grant permissions to Hasura/postgres user
GRANT USAGE ON SCHEMA bandanas TO postgres;
GRANT ALL ON ALL TABLES IN SCHEMA bandanas TO postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA bandanas TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA bandanas GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA bandanas GRANT ALL ON SEQUENCES TO postgres;

-- If tables don't exist, you'll need to run the migrations manually
-- OR untrack and retrack the tables in Hasura Console

