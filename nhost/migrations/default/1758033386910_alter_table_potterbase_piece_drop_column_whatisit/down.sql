alter table "potterbase"."piece" alter column "whatisit" drop not null;
alter table "potterbase"."piece" add column "whatisit" text;
