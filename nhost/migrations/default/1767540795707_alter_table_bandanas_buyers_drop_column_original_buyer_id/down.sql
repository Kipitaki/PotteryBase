alter table "potterbase"."buyers" alter column "original_buyer_id" drop not null;
alter table "potterbase"."buyers" add column "original_buyer_id" text;
