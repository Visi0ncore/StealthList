#!/bin/bash

# Test suite for UNCONFIGURED environments (both local and prod not configured)
# This simulates the first-run experience for new users

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0
SKIPPED=0

# Function to print test results
print_result() {
    local test_name="$1"
    local status="$2"
    local message="$3"
    
    case $status in
        "PASS")
            echo -e "✅ PASS - $test_name: $message"
            ((PASSED++))
            ;;
        "FAIL")
            echo -e "❌ FAIL - $test_name: $message"
            ((FAILED++))
            ;;
        "SKIP")
            echo -e "⏭️  SKIP - $test_name: $message"
            ((SKIPPED++))
            ;;
    esac
}

# Function to test page content
test_page() {
    local test_name="$1"
    local url="$2"
    local pattern="$3"
    local message="$4"
    
    local page_content=$(curl -s "$url")
    if echo "$page_content" | grep -q "$pattern"; then
        print_result "$test_name" "PASS" "$message"
    else
        print_result "$test_name" "FAIL" "$message"
    fi
}

# Function to test API response
test_api() {
    local test_name="$1"
    local url="$2"
    local expected_pattern="$3"
    local message="$4"
    
    local response=$(curl -s "$url")
    if echo "$response" | grep -q "$expected_pattern"; then
        print_result "$test_name" "PASS" "$message"
    else
        print_result "$test_name" "FAIL" "$message (Response: $response)"
    fi
}

# Function to test API status code
test_api_status() {
    local test_name="$1"
    local url="$2"
    local expected_status="$3"
    local message="$4"
    
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    if [ "$status_code" -eq "$expected_status" ]; then
        print_result "$test_name" "PASS" "$message"
    else
        print_result "$test_name" "FAIL" "$message (Expected: $expected_status, Got: $status_code)"
    fi
}

# Function to cleanup test data (for unconfigured tests, this is mainly for safety)
cleanup_test_data() {
    echo -e "${YELLOW}🧹 Cleaning up test data...${NC}"
    echo -e "${BLUE}ℹ️  No cleanup needed for unconfigured environment tests${NC}"
}

echo -e "${BLUE}🧪 StealthList Test Suite - UNCONFIGURED ENVIRONMENTS${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""

# Test 1: Check server status
echo -e "${YELLOW}🔍 Checking server status...${NC}"
if curl -s "http://localhost:3000" > /dev/null; then
    print_result "Server Status" "PASS" "Server is running"
else
    print_result "Server Status" "FAIL" "Server is not running"
    exit 1
fi

# Test 2: Main landing page
echo -e "${YELLOW}📄 Testing main landing page...${NC}"
test_page "Landing Page" "http://localhost:3000" "StealthList" "Main landing page loads with StealthList title"

# Test 3: Dashboard page
echo -e "${YELLOW}📊 Testing dashboard page...${NC}"
test_page "Dashboard Page" "http://localhost:3000/signups.html" "Dashboard" "Dashboard page loads with Dashboard title"

# Test 4: Waitlist stats API (should return not configured)
echo -e "${YELLOW}📈 Testing waitlist stats API...${NC}"
test_api "Waitlist Stats API" "http://localhost:3000/api/waitlist/stats" "Database not configured" "Waitlist stats API returns not configured message"

# Test 5: Local signups API (should return not configured)
echo -e "${YELLOW}🏠 Testing local signups API...${NC}"
test_api "Local Signups API" "http://localhost:3000/api/signups?env=local" "Local database not configured" "Local signups API returns not configured message"

# Test 6: Production signups API (should return not configured)
echo -e "${YELLOW}☁️ Testing production signups API...${NC}"
test_api "Production Signups API" "http://localhost:3000/api/signups?env=prod" "Production database not configured" "Production signups API returns not configured message"

# Test 7: Local export API (should return not configured)
echo -e "${YELLOW}📤 Testing local signups export API...${NC}"
test_api "Local Export API" "http://localhost:3000/api/signups/export?env=local" "Local database not configured" "Local export API returns not configured message"

# Test 8: Production export API (should return not configured)
echo -e "${YELLOW}📤 Testing production signups export API...${NC}"
test_api "Production Export API" "http://localhost:3000/api/signups/export?env=prod" "Production database not configured" "Production export API returns not configured message"

# Test 9: Waitlist signup API (should return not configured)
echo -e "${YELLOW}📝 Testing waitlist signup API...${NC}"
test_api "Waitlist Signup API" "http://localhost:3000/api/waitlist" "Database not configured" "Waitlist signup API returns not configured message"

# Test 10: UI elements for unconfigured state
echo -e "${YELLOW}🎨 Testing UI elements for unconfigured state...${NC}"
test_page "Setup Required Text" "http://localhost:3000/signups.html" "Setup Required" "Setup Required text present in dashboard"
test_page "Run Setup Button" "http://localhost:3000/signups.html" "Run Setup" "Run Setup button text present"
test_page "Setup Instructions" "http://localhost:3000/signups.html" "Click the Run Setup button" "Setup instructions present"

# Test 11: Button states for unconfigured environment
echo -e "${YELLOW}🔒 Testing button states for unconfigured environment...${NC}"
test_page "Disabled Buttons" "http://localhost:3000/signups.html" "refreshLocalBtn.*disabled.*true" "Refresh button disabled for local environment"
test_page "Disabled Buttons" "http://localhost:3000/signups.html" "refreshProdBtn.*disabled.*true" "Refresh button disabled for production environment"
test_page "Disabled Buttons" "http://localhost:3000/signups.html" "exportLocalBtn.*disabled.*true" "Export button disabled for local environment"
test_page "Disabled Buttons" "http://localhost:3000/signups.html" "exportProdBtn.*disabled.*true" "Export button disabled for production environment"

# Test 12: HTTP status codes for unconfigured environments
echo -e "${YELLOW}📊 Testing HTTP status codes for unconfigured environments...${NC}"
test_api_status "Local API Status Code" "http://localhost:3000/api/signups?env=local" "503" "Local API returns 503 Service Unavailable"
test_api_status "Production API Status Code" "http://localhost:3000/api/signups?env=prod" "503" "Production API returns 503 Service Unavailable"
test_api_status "Waitlist Stats Status Code" "http://localhost:3000/api/waitlist/stats" "503" "Waitlist stats returns 503 Service Unavailable"

# Test 13: Setup script functionality
echo -e "${YELLOW}🔧 Testing setup script functionality...${NC}"
if [ -f "./scripts/setup.sh" ] && [ -x "./scripts/setup.sh" ]; then
    print_result "Setup Script Exists" "PASS" "Setup script exists and is executable"
else
    print_result "Setup Script Exists" "FAIL" "Setup script missing or not executable"
fi

# Final cleanup
cleanup_test_data

# Print summary
echo ""
echo -e "${BLUE}📊 Test Results Summary${NC}"
echo -e "${BLUE}========================${NC}"
echo -e "${GREEN}✅ Tests Passed: $PASSED${NC}"
echo -e "${RED}❌ Tests Failed: $FAILED${NC}"
echo -e "${YELLOW}⏭️  Tests Skipped: $SKIPPED${NC}"
echo -e "${BLUE}📋 Total Tests: $((PASSED + FAILED + SKIPPED))${NC}"
echo ""

# Exit with appropriate code
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}⚠️  Some tests failed. Please check the output above.${NC}"
    exit 1
else
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
fi 