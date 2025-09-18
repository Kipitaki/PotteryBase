-- Add test_field to piece_glaze table
ALTER TABLE potterbase.piece_glaze 
ADD COLUMN test_field TEXT DEFAULT 'test_value';
