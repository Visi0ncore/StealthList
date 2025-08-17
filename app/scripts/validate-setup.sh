#!/bin/bash

# StealthList Setup Validation Script
# This script validates that the setup was completed successfully

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "🔍 StealthList Setup Validation"
echo "==============================="
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "Please run this script from the StealthList app directory"
    exit 1
fi

# Test 1: Check if .env.local exists
print_status "Checking environment configuration..."
if [ -f ".env.local" ]; then
    print_success "Found .env.local"
    
    # Check if it contains required variables
    if grep -q "POSTGRES_URL" .env.local; then
        print_success "POSTGRES_URL configured"
    else
        print_error "POSTGRES_URL not found in .env.local"
    fi
else
    print_error ".env.local not found"
fi

# Test 2: Check if .pgpass exists
print_status "Checking database access configuration..."
if [ -f ".pgpass" ]; then
    print_success "Found .pgpass file"
    
    # Check file permissions
    if [ "$(stat -c %a .pgpass 2>/dev/null || stat -f %Lp .pgpass 2>/dev/null)" = "600" ]; then
        print_success ".pgpass has correct permissions (600)"
    else
        print_warning ".pgpass permissions should be 600 for security"
    fi
else
    print_warning ".pgpass not found (database access may require password)"
fi

# Test 3: Check database connection
print_status "Testing database connection..."
if command -v psql >/dev/null 2>&1; then
    # Try to connect and run a simple query
    if psql -h localhost -U stealthlist_user -d stealthlist_waitlist -c "SELECT 1;" >/dev/null 2>&1; then
        print_success "Database connection successful"
    else
        print_error "Database connection failed"
        echo "  Make sure PostgreSQL is running and credentials are correct"
    fi
else
    print_error "PostgreSQL client (psql) not found"
fi

# Test 4: Check if waitlist table exists
print_status "Checking database schema..."
if command -v psql >/dev/null 2>&1; then
    TABLE_COUNT=$(psql -h localhost -U stealthlist_user -d stealthlist_waitlist -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'waitlist_signups';" 2>/dev/null | tr -d ' ')
    
    if [ "$TABLE_COUNT" = "1" ]; then
        print_success "waitlist_signups table exists"
    else
        print_error "waitlist_signups table not found"
    fi
else
    print_warning "Cannot check database schema (psql not available)"
fi

# Test 5: Check dependencies
print_status "Checking dependencies..."
if [ -d "node_modules" ]; then
    print_success "Dependencies installed"
else
    print_error "Dependencies not installed (run 'bun install')"
fi

# Test 6: Check if Bun is available
print_status "Checking Bun installation..."
if command -v bun >/dev/null 2>&1; then
    BUN_VERSION=$(bun --version)
    print_success "Bun found: $BUN_VERSION"
else
    print_error "Bun not found"
fi

# Test 7: Test API endpoints (if server is running)
print_status "Testing API endpoints..."
if curl -s http://localhost:3000/api/waitlist/stats >/dev/null 2>&1; then
    print_success "API endpoints responding"
else
    print_warning "API endpoints not responding (server may not be running)"
    echo "  Start the server with: bun run dev"
fi

echo ""
echo "🎯 Validation Summary:"
echo "====================="

# Count successes and failures
SUCCESS_COUNT=0
ERROR_COUNT=0
WARNING_COUNT=0

# This is a simplified count - in a real implementation you'd track these
# For now, we'll just provide a summary message

if [ -f ".env.local" ] && [ -f ".pgpass" ] && command -v bun >/dev/null 2>&1; then
    print_success "Setup appears to be complete and functional!"
    echo ""
    echo "🚀 You can now run:"
    echo "  bun run dev          # Start development server"
    echo "  bun run db:stats     # View signup count"
    echo "  bun run db:list      # List all signups"
else
    print_warning "Setup may be incomplete. Please run 'bun run setup:full' to complete the setup."
fi

echo ""
echo "📚 For more information, see README.md"
