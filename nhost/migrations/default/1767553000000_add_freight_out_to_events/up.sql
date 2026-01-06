ALTER TABLE bandanas.events
ADD COLUMN IF NOT EXISTS freight_out DECIMAL(18,2);

COMMENT ON COLUMN bandanas.events.freight_out IS 'Freight costs for previous years that should not be added per line item';

