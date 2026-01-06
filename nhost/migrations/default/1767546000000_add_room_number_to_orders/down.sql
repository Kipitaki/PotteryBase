-- Remove the room_number column from orders table
ALTER TABLE potterbase.orders
DROP COLUMN IF EXISTS room_number;

