-- Add missing columns to buyers table
ALTER TABLE bandanas.buyers
ADD COLUMN IF NOT EXISTS original_buyer_id TEXT;

CREATE INDEX IF NOT EXISTS idx_buyers_original_buyer_id ON bandanas.buyers(original_buyer_id);
COMMENT ON COLUMN bandanas.buyers.original_buyer_id IS 'Stores the original buyer ID from external systems (e.g., Salesforce) for mapping purposes when importing related data';

-- Add missing columns to buyer_addresses table
ALTER TABLE bandanas.buyer_addresses
ADD COLUMN IF NOT EXISTS original_address_id TEXT;

CREATE INDEX IF NOT EXISTS idx_buyer_addresses_original_address_id ON bandanas.buyer_addresses(original_address_id);
COMMENT ON COLUMN bandanas.buyer_addresses.original_address_id IS 'Stores the original address ID from external systems (e.g., Salesforce) for mapping purposes when importing related data';

-- Add missing columns to orders table
ALTER TABLE bandanas.orders
ADD COLUMN IF NOT EXISTS fee DECIMAL(18,2) CHECK (fee >= 0),
ADD COLUMN IF NOT EXISTS room_number TEXT,
ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'Ordered' 
  CHECK (status IN ('Ordered', 'Pending Shipping', 'Tracking Created', 'Shipped', 'Received', 'Other')),
ADD COLUMN IF NOT EXISTS order_number TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS tracking_number TEXT,
ADD COLUMN IF NOT EXISTS usps_zone INTEGER,
ADD COLUMN IF NOT EXISTS length DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS width DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS height DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS weight DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS estimated_postage_cost DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS actual_postage_cost DECIMAL(10,2);

-- Create indexes for orders
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON bandanas.orders(order_number);
CREATE INDEX IF NOT EXISTS idx_orders_tracking_number ON bandanas.orders(tracking_number);

-- Add comments for orders columns
COMMENT ON COLUMN bandanas.orders.fee IS 'Additional fee charged on the order';
COMMENT ON COLUMN bandanas.orders.room_number IS 'Room number for the order (e.g., cabin number, hotel room)';
COMMENT ON COLUMN bandanas.orders.status IS 'Order status';
COMMENT ON COLUMN bandanas.orders.order_number IS 'Unique order number for matching during import/export';
COMMENT ON COLUMN bandanas.orders.tracking_number IS 'Shipping tracking number';

-- Add missing columns to events table
ALTER TABLE bandanas.events
ADD COLUMN IF NOT EXISTS bandana_cost DECIMAL(18,2) CHECK (bandana_cost >= 0),
ADD COLUMN IF NOT EXISTS freight DECIMAL(18,2) CHECK (freight >= 0),
ADD COLUMN IF NOT EXISTS fee_tax_transaction_fees DECIMAL(18,2) CHECK (fee_tax_transaction_fees >= 0),
ADD COLUMN IF NOT EXISTS freight_out DECIMAL(18,2),
ADD COLUMN IF NOT EXISTS total_qty INTEGER CHECK (total_qty >= 0),
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Add comments for events columns
COMMENT ON COLUMN bandanas.events.bandana_cost IS 'Cost per bandana';
COMMENT ON COLUMN bandanas.events.freight IS 'Freight/shipping cost';
COMMENT ON COLUMN bandanas.events.fee_tax_transaction_fees IS 'Fee, tax, and transaction fees';
COMMENT ON COLUMN bandanas.events.freight_out IS 'Freight costs for previous years that should not be added per line item';
COMMENT ON COLUMN bandanas.events.total_qty IS 'Total quantity of bandanas';
COMMENT ON COLUMN bandanas.events.image_url IS 'URL to the bandana image (square image)';
