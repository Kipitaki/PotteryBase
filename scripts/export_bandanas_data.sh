#!/bin/bash
# Export Bandanas Data Script (Shell version using pg_dump)
# This exports only the bandanas schema data to SQL format
# 
# Usage: ./scripts/export_bandanas_data.sh [output_file]
# 
# Default output: bandanas_data_export.sql

OUTPUT_FILE="${1:-bandanas_data_export.sql}"

# Local database connection (adjust if needed)
LOCAL_DB="postgres://postgres:postgres@localhost:5432/postgres"

echo "Exporting bandanas data from local database..."
echo "Output file: $OUTPUT_FILE"

# Export only data (no schema) for bandanas schema
pg_dump "$LOCAL_DB" \
  --schema=bandanas \
  --data-only \
  --column-inserts \
  --no-owner \
  --no-privileges \
  --file="$OUTPUT_FILE"

if [ $? -eq 0 ]; then
  echo "✅ Export completed successfully!"
  echo "📁 File saved to: $OUTPUT_FILE"
  echo ""
  echo "Next steps:"
  echo "1. Review the exported file"
  echo "2. Run: ./scripts/import_bandanas_data.sh $OUTPUT_FILE"
else
  echo "❌ Export failed!"
  exit 1
fi

