-- Add USPS zone column to orders table
ALTER TABLE bandanas.orders
ADD COLUMN IF NOT EXISTS usps_zone INTEGER;

-- Add comment
COMMENT ON COLUMN bandanas.orders.usps_zone IS 'USPS shipping zone (1-9) based on destination zip code, shipping from 32207';

