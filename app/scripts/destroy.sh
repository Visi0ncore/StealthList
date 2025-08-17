#!/bin/bash

# StealthList Local Environment Destroyer
# This script completely removes the local database setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_danger() {
    echo -e "${RED}🔥 $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect PostgreSQL superuser
detect_postgres_superuser() {
    print_status "Checking if psql command is available..."
    if ! command_exists psql; then
        print_error "psql command not found in PATH"
        print_status "Trying to add PostgreSQL to PATH..."
        export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
        if ! command_exists psql; then
            print_error "Still cannot find psql after adding to PATH"
            return 1
        else
            print_success "Found psql after adding to PATH"
        fi
    else
        print_success "psql command found in PATH"
    fi
    
    print_status "Testing PostgreSQL connection..."
    if psql postgres -c "SELECT 1;" >/dev/null 2>&1; then
        print_success "Connected to PostgreSQL as current user"
        return 0
    else
        print_error "Cannot connect to PostgreSQL"
        print_status "Troubleshooting:"
        echo "  - Ensure PostgreSQL is running: brew services start postgresql@15"
        echo "  - Check if PostgreSQL is accessible: psql postgres -c 'SELECT 1;'"
        return 1
    fi
}

echo ""
print_status "📂 Directory Validation"
# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "Please run this script from the StealthList app directory"
    exit 1
fi
print_success "Running from correct directory"

echo ""
echo "🔥 StealthList Local Environment Destroyer"
echo "=========================================="
echo ""
echo "This will completely destroy your local setup!"
echo ""
echo "This includes:"
echo "  • Database"
echo "  • User"
echo "  • All local signup data"
echo "  • Environment files (.env.local)"
echo "  • Database access files (.pgpass)"
echo ""
print_status "☑️ Destruction Confirmation"
echo "Are you absolutely sure you want to continue?"
read -p "(type 'DESTROY' to confirm): " confirmation

if [ "$confirmation" != "DESTROY" ]; then
    print_warning "Destruction cancelled. Your setup remains intact."
    exit 0
fi
print_success "Destruction confirmed"

echo ""
print_danger "DESTROYING SETUP..."

# Check PostgreSQL
if ! command_exists psql; then
    print_error "PostgreSQL client (psql) not found. Cannot destroy database."
    exit 1
fi

# Detect PostgreSQL superuser
echo ""
print_status "🔌 PostgreSQL Connection Testing"
DETECTION_RESULT=0
if detect_postgres_superuser; then
    PG_SUPERUSER="current_user"
else
    DETECTION_RESULT=1
fi

if [ $DETECTION_RESULT -ne 0 ]; then
    print_error "Failed to connect to PostgreSQL. Cannot destroy database."
    print_status "Troubleshooting steps:"
    echo "  1. Ensure PostgreSQL is running: brew services start postgresql@15"
    echo "  2. Check if PostgreSQL is accessible: psql postgres -c 'SELECT 1;'"
    echo "  3. Verify PATH includes PostgreSQL: echo \$PATH | grep postgresql"
    echo ""
    print_warning "Skipping database destruction due to connection failure."
    DB_DESTROYED=false
else
    print_success "PostgreSQL connection established"
    DB_DESTROYED=true
fi

# Stop any running development server
echo ""
print_status "🔫 Development Server Termination"
pkill -f "next dev" 2>/dev/null || true
pkill -f "bun.*dev" 2>/dev/null || true
print_success "Development server stopped"

# Destroy database and user
if [ "$DB_DESTROYED" = true ]; then
    echo ""
    print_status "💣 Database Destruction"
    
    DB_NAME="stealthlist_waitlist"
    DB_USER="stealthlist_user"
    
    print_status "Drop Database"
    if [ "$PG_SUPERUSER" = "current_user" ]; then
        psql postgres -c "DROP DATABASE IF EXISTS $DB_NAME;" >/dev/null 2>&1
        print_success "Dropped database"
    elif [ -n "$PG_SUPERUSER" ]; then
        psql -U "$PG_SUPERUSER" -c "DROP DATABASE IF EXISTS $DB_NAME;" >/dev/null 2>&1
        print_success "Dropped database"
    else
        psql postgres -c "DROP DATABASE IF EXISTS $DB_NAME;" >/dev/null 2>&1
        print_success "Dropped database"
    fi
    
    print_status "Drop User"
    if [ "$PG_SUPERUSER" = "current_user" ]; then
        psql postgres -c "DROP USER IF EXISTS $DB_USER;" >/dev/null 2>&1
        print_success "Dropped user"
    elif [ -n "$PG_SUPERUSER" ]; then
        psql -U "$PG_SUPERUSER" -c "DROP USER IF EXISTS $DB_USER;" >/dev/null 2>&1
        print_success "Dropped user"
    else
        psql postgres -c "DROP USER IF EXISTS $DB_USER;" >/dev/null 2>&1
        print_success "Dropped user"
    fi
else
    print_warning "Skipping database destruction - PostgreSQL connection failed"
fi

# Remove environment files
echo ""
print_status "🗑️ Environment File Removal"

print_status "Remove .env.local"
if [ -f ".env.local" ]; then
    rm .env.local
    print_success "Removed .env.local"
else
    print_warning ".env.local not found"
fi

print_status "Remove .pgpass"
if [ -f ".pgpass" ]; then
    rm .pgpass
    print_success "Removed .pgpass"
else
    print_warning ".pgpass not found"
fi

# Remove any temporary credential files
echo ""
print_status "🧹 Cleaning up temporary files..."
print_status "Remove .db_name"
rm -f .db_name
print_status "Remove .db_user"
rm -f .db_user
print_status "Remove .db_password"
rm -f .db_password
print_success "Removed temporary credential files"

# Clear any cached data
echo ""
print_status "♻️ Next.js Cache Cleanup"
rm -rf .next 2>/dev/null || true
print_success "Cleared Next.js cache"

echo ""
print_success "SETUP DESTROYED SUCCESSFULLY!"
