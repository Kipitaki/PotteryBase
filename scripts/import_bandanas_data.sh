#!/bin/bash
# Import Bandanas Data Script (Shell version using psql)
# This imports bandanas data from a SQL file to the remote database
# 
# Usage: ./scripts/import_bandanas_data.sh [input_file] [remote_db_url]
# 
# Example:
#   ./scripts/import_bandanas_data.sh bandanas_data_export.sql "postgres://user:pass@host:5432/dbname"
#
# Or set REMOTE_DB_URL environment variable:
#   export REMOTE_DB_URL="postgres://user:pass@host:5432/dbname"
#   ./scripts/import_bandanas_data.sh bandanas_data_export.sql

INPUT_FILE="${1:-bandanas_data_export.sql}"
REMOTE_DB="${2:-$REMOTE_DB_URL}"

if [ -z "$REMOTE_DB" ]; then
  echo "❌ Error: Remote database URL not provided!"
  echo ""
  echo "Usage:"
  echo "  ./scripts/import_bandanas_data.sh [input_file] [remote_db_url]"
  echo ""
  echo "Or set REMOTE_DB_URL environment variable:"
  echo "  export REMOTE_DB_URL='postgres://user:pass@host:5432/dbname'"
  echo "  ./scripts/import_bandanas_data.sh $INPUT_FILE"
  echo ""
  echo "To get your remote database URL:"
  echo "  1. Go to your Nhost dashboard"
  echo "  2. Navigate to Database > Settings"
  echo "  3. Copy the connection string"
  exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ Error: Input file not found: $INPUT_FILE"
  exit 1
fi

echo "Importing bandanas data to remote database..."
echo "Input file: $INPUT_FILE"
echo "Remote DB: ${REMOTE_DB%%:*}" # Show only protocol and host for security
echo ""
read -p "⚠️  This will import data to the remote database. Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

# Import the SQL file
psql "$REMOTE_DB" -f "$INPUT_FILE"

if [ $? -eq 0 ]; then
  echo "✅ Import completed successfully!"
else
  echo "❌ Import failed!"
  exit 1
fi

