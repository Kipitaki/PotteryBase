-- Add new fields to events table
ALTER TABLE potterbase.events
ADD COLUMN IF NOT EXISTS bandana_cost DECIMAL(18,2) CHECK (bandana_cost >= 0),
ADD COLUMN IF NOT EXISTS freight DECIMAL(18,2) CHECK (freight >= 0),
ADD COLUMN IF NOT EXISTS fee_tax_transaction_fees DECIMAL(18,2) CHECK (fee_tax_transaction_fees >= 0),
ADD COLUMN IF NOT EXISTS total_qty INTEGER CHECK (total_qty >= 0);

-- Add comments
COMMENT ON COLUMN potterbase.events.bandana_cost IS 'Cost per bandana';
COMMENT ON COLUMN potterbase.events.freight IS 'Freight/shipping cost';
COMMENT ON COLUMN potterbase.events.fee_tax_transaction_fees IS 'Fee, tax, and transaction fees';
COMMENT ON COLUMN potterbase.events.total_qty IS 'Total quantity of bandanas';

