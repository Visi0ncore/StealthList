#!/bin/bash

# StealthList Complete Setup Script
# This script automates the entire Quick Start process

set -e  # Exit on any error

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

# Function to detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        CYGWIN*)    echo "windows";;
        MINGW*)     echo "windows";;
        *)          echo "unknown";;
    esac
}

# Function to check PostgreSQL installation
check_postgresql() {
    print_status "🕵️‍♂️ Checking PostgreSQL installation..."
    
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
        PSQL_VERSION=$(psql --version | head -n1)
        print_success "PostgreSQL found: $PSQL_VERSION"
    fi
    
    print_status "Testing PostgreSQL connection..."
    if psql postgres -c "SELECT 1;" >/dev/null 2>&1; then
        print_success "Connected to PostgreSQL"
        return 0
    else
        print_error "Cannot connect to PostgreSQL"
        print_status "Troubleshooting:"
        echo "  - Ensure PostgreSQL is running: brew services start postgresql@15"
        echo "  - Check if PostgreSQL is accessible: psql postgres -c 'SELECT 1;'"
        return 1
    fi
}

# Function to provide PostgreSQL installation instructions
install_postgresql_instructions() {
    local os=$(detect_os)
    
    print_error "PostgreSQL is not installed. Please install it first:"
    echo ""
    
    case $os in
        "macos")
            echo "Using Homebrew:"
            echo "  brew install postgresql@15"
            echo "  brew services start postgresql@15"
            echo ""
            echo "Or download from: https://www.postgresql.org/download/macosx/"
            ;;
        "linux")
            echo "Ubuntu/Debian:"
            echo "  sudo apt update"
            echo "  sudo apt install postgresql postgresql-contrib"
            echo "  sudo systemctl start postgresql"
            echo "  sudo systemctl enable postgresql"
            echo ""
            echo "CentOS/RHEL/Fedora:"
            echo "  sudo dnf install postgresql postgresql-server"
            echo "  sudo postgresql-setup --initdb"
            echo "  sudo systemctl start postgresql"
            echo "  sudo systemctl enable postgresql"
            ;;
        "windows")
            echo "Download from: https://www.postgresql.org/download/windows/"
            echo "Or use Chocolatey:"
            echo "  choco install postgresql"
            ;;
        *)
            echo "Please visit: https://www.postgresql.org/download/"
            ;;
    esac
    
    echo ""
    echo "After installation, restart your terminal and run this script again."
    exit 1
}

# Function to generate secure password
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Function to create database and user
setup_database() {
    echo ""
    print_status "🔌 Setting up PostgreSQL database and user"
    
    # Generate secure credentials
    print_status "Generating database credentials..."
    DB_NAME="stealthlist_waitlist"
    DB_USER="stealthlist_user"
    DB_PASSWORD=$(generate_password)
    
    print_success "Generated database credentials"
    
    # Create database and user
    print_status "Creating database and user..."
    
    # Check if user exists
    print_status "Checking if user exists..."
    if psql postgres -t -c "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER';" 2>/dev/null | grep -q 1; then
        print_success "User already exists"
    else
        print_status "Creating user..."
        if psql postgres -c "CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASSWORD';" >/dev/null 2>&1; then
            print_success "Created user"
        else
            print_error "Failed to create user"
            exit 1
        fi
    fi
    
    # Check if database exists
    print_status "Checking if database exists..."
    if psql postgres -t -c "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';" 2>/dev/null | grep -q 1; then
        print_success "Database already exists"
    else
        print_status "Creating database..."
        if psql postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" >/dev/null 2>&1; then
            print_success "Created database"
        else
            print_error "Failed to create database"
            exit 1
        fi
    fi
    
    # Grant privileges
    psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" 2>/dev/null || true
    
    # Create the waitlist table
    print_status "Checking if table exists..."
    if psql -d "$DB_NAME" -t -c "SELECT 1 FROM information_schema.tables WHERE table_name='waitlist_signups';" 2>/dev/null | grep -q 1; then
        print_success "Table already exists"
    else
        print_status "Creating waitlist table..."
        if cat <<EOF | psql -d "$DB_NAME" >/dev/null 2>&1
CREATE TABLE waitlist_signups (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF
        then
            print_success "Created table"
        else
            print_error "Failed to create table"
            exit 1
        fi
    fi
    
    # Grant permissions on table and sequence
    print_status "Setting up table permissions..."
    
    cat <<EOF | psql -d "$DB_NAME"
-- Grant permissions on the table
GRANT ALL PRIVILEGES ON TABLE waitlist_signups TO $DB_USER;

-- Grant permissions on the sequence (for auto-incrementing IDs)
GRANT USAGE, SELECT ON SEQUENCE waitlist_signups_id_seq TO $DB_USER;
EOF
    
    print_success "Database setup complete!"
    
    # Store credentials for later use
    echo "$DB_NAME" > .db_name
    echo "$DB_USER" > .db_user
    echo "$DB_PASSWORD" > .db_password
}

# Function to create environment files
setup_environment() {
    echo ""
    print_status "🪄 Generate environment files"
    
    # Read stored credentials
    if [ -f .db_name ] && [ -f .db_user ] && [ -f .db_password ]; then
        DB_NAME=$(cat .db_name)
        DB_USER=$(cat .db_user)
        DB_PASSWORD=$(cat .db_password)
    else
        print_error "Database credentials not found. Please run database setup first."
        exit 1
    fi
    
    # Create .env.local
    print_status "Creating .env.local..."
    
    cat > .env.local <<EOF
# StealthList Local Environment Configuration
# Generated automatically by setup script

POSTGRES_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
POSTGRES_PRISMA_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME?pgbouncer=true&connect_timeout=15"
POSTGRES_URL_NON_POOLING="postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"

# Security settings
RATE_LIMIT_MAX_REQUESTS=5
RATE_LIMIT_WINDOW_MS=3600000
BURST_LIMIT_MAX_REQUESTS=3
BURST_LIMIT_WINDOW_MS=60000
EMAIL_COOLDOWN_HOURS=24
IP_BLOCK_DURATION_HOURS=1
EOF
    
    print_success "Created .env.local"
    
    # Create .pgpass file for password-free access
    print_status "Creating .pgpass..."
    
    cat > .pgpass <<EOF
localhost:5432:$DB_NAME:$DB_USER:$DB_PASSWORD
EOF
    
    chmod 600 .pgpass
    export PGPASSFILE=.pgpass
    
    print_success "Created .pgpass"
}

# Function to install dependencies
install_dependencies() {
    echo ""
    print_status "📦 Installing Bun dependencies..."
    
    if ! command_exists bun; then
        print_error "Bun is not installed. Please install Bun first:"
        echo "  curl -fsSL https://bun.sh/install | bash"
        echo "  Or visit: https://bun.sh/docs/installation"
        exit 1
    fi
    
    bun install
    
    print_success "Dependencies installed successfully"
}

# Function to test the setup
test_setup() {
    echo ""
    print_status "🧪 Testing Setup"
    
    print_status "Testing database connection..."
    
    # Test connection using the new credentials
    if psql -h localhost -U "$DB_USER" -d "$DB_NAME" -c "SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_name = 'waitlist_signups';" >/dev/null 2>&1; then
        print_success "Database connection successful"
    else
        print_error "Database connection failed!"
        echo "Please check your PostgreSQL installation and try again."
        exit 1
    fi
    
    print_status "Testing API endpoints..."
    
    # Start the development server in the background
    print_status "Starting dev server for testing..."
    bun run dev > /dev/null 2>&1 &
    DEV_SERVER_PID=$!
    
    # Wait for server to start
    sleep 5
    
    # Test the stats endpoint
    if curl -s http://localhost:3000/api/waitlist/stats >/dev/null 2>&1; then
        print_success "API endpoints working correctly"
    else
        print_warning "API endpoints test failed"
    fi
    
    # Stop the development server
    kill $DEV_SERVER_PID 2>/dev/null || true
    
    print_success "Setup test completed"
}

# Function to cleanup temporary files
cleanup() {
    echo ""
    print_status "🧹 Cleaning up temporary files..."
    
    # Remove credential files
    rm -f .db_name .db_user .db_password
    
    print_success "Cleanup complete"
}

# Function to show next steps
show_next_steps() {
    echo ""    
    echo "🎉 Your StealthList environment is ready!"
    print_status "Starting development server..."
    echo ""
    bun run dev
}

# Main execution
main() {
    echo ""
    echo "🥷 StealthList Setup"
    echo "===================="
    echo ""
    
    # Check if we're in the right directory
    if [ ! -f "package.json" ]; then
        print_error "Please run this script from the StealthList app directory"
        exit 1
    fi
    
    # Check PostgreSQL
    if ! check_postgresql; then
        install_postgresql_instructions
    fi
    
    # Run setup steps
    install_dependencies
    setup_database
    setup_environment
    test_setup
    cleanup
    show_next_steps
}

# Handle script interruption
trap 'print_error "Setup interrupted. Cleaning up..."; cleanup; exit 1' INT TERM

# Run main function
main "$@"
