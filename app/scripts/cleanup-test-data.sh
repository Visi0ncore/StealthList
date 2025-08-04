#!/bin/bash

# StealthList Test Data Cleanup Script
# This script cleans up test data to ensure consistent starting points for tests

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 StealthList Test Data Cleanup${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Function to detect environment configuration
detect_environment() {
    echo -e "${BLUE}🔍 Detecting environment configuration...${NC}"
    
    # Test local environment
    local local_response=$(curl -s "http://localhost:3000/api/signups?env=local")
    if echo "$local_response" | grep -q '"error"'; then
        LOCAL_CONFIGURED=false
        echo -e "${YELLOW}🏠 Local environment: NOT CONFIGURED${NC}"
    else
        LOCAL_CONFIGURED=true
        local total_signups=$(echo "$local_response" | grep -o '"totalSignups":[0-9]*' | cut -d':' -f2)
        echo -e "${GREEN}🏠 Local environment: CONFIGURED (${total_signups} signups)${NC}"
    fi
    
    # Test production environment
    local prod_response=$(curl -s "http://localhost:3000/api/signups?env=prod")
    if echo "$prod_response" | grep -q '"error"'; then
        PROD_CONFIGURED=false
        echo -e "${YELLOW}☁️  Production environment: NOT CONFIGURED${NC}"
    else
        PROD_CONFIGURED=true
        local total_signups=$(echo "$prod_response" | grep -o '"totalSignups":[0-9]*' | cut -d':' -f2)
        echo -e "${GREEN}☁️  Production environment: CONFIGURED (${total_signups} signups)${NC}"
    fi
    
    echo ""
}

# Function to cleanup local environment
cleanup_local() {
    if [ "$LOCAL_CONFIGURED" = true ]; then
        echo -e "${YELLOW}🧹 Cleaning up local environment...${NC}"
        local cleanup_response=$(curl -s -X DELETE "http://localhost:3000/api/signups?env=local")
        if echo "$cleanup_response" | grep -q '"success":true'; then
            local deleted_count=$(echo "$cleanup_response" | grep -o '"deletedCount":[0-9]*' | cut -d':' -f2)
            echo -e "${GREEN}✅ Local environment cleaned up (${deleted_count} signups deleted)${NC}"
        else
            echo -e "${YELLOW}⚠️  Local environment cleanup failed or no data to clean${NC}"
        fi
    else
        echo -e "${BLUE}ℹ️  Local environment not configured - no cleanup needed${NC}"
    fi
}

# Function to reset to initial state
reset_to_initial() {
    echo -e "${YELLOW}🔄 Resetting to initial state...${NC}"
    
    # Clean up local environment only
    cleanup_local
    
    # Production environment is never touched for safety
    if [ "$PROD_CONFIGURED" = true ]; then
        echo -e "${BLUE}ℹ️  Production environment left unchanged (real data preserved)${NC}"
    fi
    
    echo -e "${GREEN}✅ Reset complete! (Local only)${NC}"
}

# Function to add sample data for testing
add_sample_data() {
    if [ "$LOCAL_CONFIGURED" = true ]; then
        echo -e "${YELLOW}📝 Adding sample data to local environment...${NC}"
        local add_response=$(curl -s -X POST "http://localhost:3000/api/signups/add-mock" -H "Content-Type: application/json" -d '{"count": 5}')
        if echo "$add_response" | grep -q '"success":true'; then
            local count=$(echo "$add_response" | grep -o '"count":[0-9]*' | cut -d':' -f2)
            echo -e "${GREEN}✅ Added ${count} sample users to local environment${NC}"
        else
            echo -e "${RED}❌ Failed to add sample data${NC}"
        fi
    else
        echo -e "${BLUE}ℹ️  Local environment not configured - cannot add sample data${NC}"
    fi
}

# Main execution
if [ "$1" = "reset" ]; then
    # Check if server is running
    if ! curl -s "http://localhost:3000" > /dev/null; then
        echo -e "${RED}❌ Server not running. Please start the server with: bun run dev${NC}"
        exit 1
    fi
    
    detect_environment
    reset_to_initial
elif [ "$1" = "sample" ]; then
    # Check if server is running
    if ! curl -s "http://localhost:3000" > /dev/null; then
        echo -e "${RED}❌ Server not running. Please start the server with: bun run dev${NC}"
        exit 1
    fi
    
    detect_environment
    add_sample_data
else
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  ${GREEN}./scripts/cleanup-test-data.sh reset${NC}  - Reset all environments to clean state"
    echo -e "  ${GREEN}./scripts/cleanup-test-data.sh sample${NC} - Add sample data to local environment"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  ${BLUE}./scripts/cleanup-test-data.sh reset${NC}  # Clean slate for testing"
    echo -e "  ${BLUE}./scripts/cleanup-test-data.sh sample${NC} # Add test data"
    exit 1
fi 