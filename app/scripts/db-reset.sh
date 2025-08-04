#!/bin/bash

# Script to reset the StealthList waitlist database
# Usage: ./db-reset.sh

# Check if .env.local exists
if [ ! -f .env.local ]; then
    echo "❌ Error: .env.local file not found!"
    echo ""
    echo "Please set up your local database configuration:"
    echo "1. Copy .env.example.local to .env.local"
    echo "2. Update .env.local with your database credentials"
    echo "3. Run this script again"
    exit 1
fi

# Source local environment variables
source .env.local

# Check if POSTGRES_URL is set
if [ -z "$POSTGRES_URL" ]; then
    echo "❌ Error: POSTGRES_URL is not set in .env.local"
    echo "Please configure your database connection string in .env.local"
    exit 1
fi

# Extract database connection details from POSTGRES_URL
DB_URL="${POSTGRES_URL#postgresql://}"
DB_USER_PASS="${DB_URL%%@*}"
DB_USER="${DB_USER_PASS%%:*}"
DB_PASS="${DB_USER_PASS#*:}"
DB_HOST_PORT_DB="${DB_URL#*@}"
DB_HOST_PORT="${DB_HOST_PORT_DB%%/*}"
DB_HOST="${DB_HOST_PORT%%:*}"
DB_PORT="${DB_HOST_PORT#*:}"
DB_NAME="${DB_HOST_PORT_DB#*/}"

# Remove query parameters from DB_NAME if present
DB_NAME="${DB_NAME%%\?*}"

# Validate extracted values
if [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_NAME" ]; then
    echo "❌ Error: Invalid POSTGRES_URL format in .env.local"
    echo "Expected format: postgresql://username:password@host:port/database"
    echo "Current value: $POSTGRES_URL"
    exit 1
fi

echo "🚨 WARNING: This will delete ALL waitlist signups!"
echo "Database: $DB_NAME on $DB_HOST:$DB_PORT"
echo "Current signup count:"
PGPASSWORD="$DB_PASS" psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) as total_signups FROM waitlist_signups;"

echo ""
read -p "Are you sure you want to delete all signups? (type 'yes' to confirm): " confirmation

if [ "$confirmation" = "yes" ]; then
    echo "🗑️ Deleting all waitlist signups..."
    PGPASSWORD="$DB_PASS" psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "DELETE FROM waitlist_signups;"
    
    echo ""
    echo "✅ Database reset complete!"

    echo ""
    echo "New signup count:"
    PGPASSWORD="$DB_PASS" psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) as total_signups FROM waitlist_signups;"
else
    echo "❌ Reset cancelled. No data was deleted."
fi 