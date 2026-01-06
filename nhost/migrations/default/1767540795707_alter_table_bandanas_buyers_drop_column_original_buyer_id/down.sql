alter table "bandanas"."buyers" alter column "original_buyer_id" drop not null;
alter table "bandanas"."buyers" add column "original_buyer_id" text;
