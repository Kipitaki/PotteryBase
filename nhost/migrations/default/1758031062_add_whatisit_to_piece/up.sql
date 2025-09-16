-- Add whatisit column to piece table after title column
ALTER TABLE potterbase.piece 
ADD COLUMN whatisit text NULL;
