alter table "potterbase"."piece" alter column "description" drop not null;
alter table "potterbase"."piece" add column "description" text;
