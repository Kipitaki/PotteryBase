-- Add room_number column to orders table
ALTER TABLE potterbase.orders
ADD COLUMN IF NOT EXISTS room_number TEXT;

-- Add comment
COMMENT ON COLUMN potterbase.orders.room_number IS 'Room number for the order (e.g., cabin number, hotel room)';

