# Bandanas Data Migration Guide

This guide explains how to export data from your local database and import it to the remote database.

## Option 1: Using Hasura Console (Easiest)

### Step 1: Export from Local

1. Open your **local** Hasura Console (usually at `http://localhost:1337`)
2. Go to the **Data** tab → **SQL Editor**
3. Open the file `scripts/export_bandanas_data.sql`
4. Run each SELECT statement one at a time (they generate INSERT statements)
5. Copy all the INSERT statements from the results
6. Save them to a file (e.g., `bandanas_data_export.sql`)

**Note:** Run the queries in this order:
- buyers
- events  
- buyer_addresses
- orders
- shipping_rates

### Step 2: Import to Remote

1. Open your **remote** Hasura Console (from Nhost dashboard)
2. Go to the **Data** tab → **SQL Editor**
3. Open the file `scripts/import_bandanas_data.sql`
4. Paste your INSERT statements into the SQL editor
5. Add `ON CONFLICT (id) DO NOTHING;` to each INSERT if you want to skip duplicates
6. Run the script

## Option 2: Using Shell Scripts (Requires pg_dump/psql)

### Prerequisites

- `pg_dump` and `psql` installed (usually comes with PostgreSQL)
- Access to both local and remote database connection strings

### Step 1: Export from Local

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Export data (uses local database by default)
./scripts/export_bandanas_data.sh bandanas_data_export.sql
```

This will create a SQL file with all your bandanas data.

### Step 2: Get Remote Database URL

1. Go to your Nhost dashboard
2. Navigate to **Database** → **Settings**
3. Copy the connection string (looks like: `postgres://user:password@host:5432/dbname`)

### Step 3: Import to Remote

```bash
# Option A: Pass URL as argument
./scripts/import_bandanas_data.sh bandanas_data_export.sql "postgres://user:pass@host:5432/dbname"

# Option B: Set environment variable (more secure)
export REMOTE_DB_URL="postgres://user:pass@host:5432/dbname"
./scripts/import_bandanas_data.sh bandanas_data_export.sql
```

## Option 3: Using pg_dump Directly

### Export

```bash
pg_dump "postgres://postgres:postgres@localhost:5432/postgres" \
  --schema=bandanas \
  --data-only \
  --column-inserts \
  --no-owner \
  --no-privileges \
  --file=bandanas_data_export.sql
```

### Import

```bash
psql "YOUR_REMOTE_DB_URL" -f bandanas_data_export.sql
```

## Troubleshooting

### Foreign Key Constraint Errors

If you get foreign key errors, make sure you're importing in the correct order:
1. buyers
2. events
3. buyer_addresses
4. orders
5. shipping_rates

### Duplicate Key Errors

Add `ON CONFLICT (id) DO NOTHING;` or `ON CONFLICT (id) DO UPDATE SET ...` to your INSERT statements to handle duplicates.

### Missing Tables

Make sure all tables exist in the remote database before importing. Run the migration scripts first if needed.

## Security Notes

- Never commit database connection strings to git
- Use environment variables for sensitive credentials
- The `.env` file is already in `.gitignore`

