#!/bin/bash

# StealthList Test Suite
# This script tests all functionality from first-run experience to API endpoints

# Don't exit on error, let tests continue

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_result() {
    local test_name="$1"
    local status="$2"
    local message="$3"
    
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✅ PASS${NC} - $test_name: $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} - $test_name: $message"
        ((TESTS_FAILED++))
    fi
}

# Function to check if server is running
check_server() {
    if ! curl -s http://localhost:3000/ > /dev/null 2>&1; then
        echo -e "${RED}❌ Server not running on localhost:3000${NC}"
        echo -e "${YELLOW}Please start the server with: bun run dev${NC}"
        exit 1
    fi
}

# Function to make API request and validate response
test_api() {
    local test_name="$1"
    local endpoint="$2"
    local expected_pattern="$3"
    local description="$4"
    
    local response
    response=$(curl -s "$endpoint" 2>/dev/null || echo "ERROR")
    
    if echo "$response" | grep -q "$expected_pattern"; then
        print_result "$test_name" "PASS" "$description"
    else
        print_result "$test_name" "FAIL" "Expected pattern '$expected_pattern' not found in response"
        echo "Response: $response"
    fi
}

# Function to test page loads
test_page() {
    local test_name="$1"
    local page="$2"
    local expected_pattern="$3"
    local description="$4"
    
    local response
    response=$(curl -s "$page" 2>/dev/null || echo "ERROR")
    
    if echo "$response" | grep -q "$expected_pattern"; then
        print_result "$test_name" "PASS" "$description"
    else
        print_result "$test_name" "FAIL" "Expected pattern '$expected_pattern' not found in page"
    fi
}

echo -e "${BLUE}🧪 StealthList Test Suite${NC}"
echo "=================================="
echo ""

# Check if server is running
echo -e "${YELLOW}🔍 Checking server status...${NC}"
check_server
echo -e "${GREEN}✅ Server is running${NC}"
echo ""

# Test 1: Main landing page loads
echo -e "${YELLOW}📄 Testing main landing page...${NC}"
test_page "Landing Page" "http://localhost:3000/" "StealthList" "Main landing page loads with StealthList title"

# Test 2: Dashboard page loads
echo -e "${YELLOW}📊 Testing dashboard page...${NC}"
test_page "Dashboard Page" "http://localhost:3000/signups.html" "Dashboard" "Dashboard page loads with Dashboard title"

# Test 3: Waitlist stats API (first-run experience)
echo -e "${YELLOW}📈 Testing waitlist stats API...${NC}"
test_api "Waitlist Stats API" "http://localhost:3000/api/waitlist/stats" "Database not configured" "Returns setup message when database not configured"

# Test 4: Local signups API (first-run experience)
echo -e "${YELLOW}🏠 Testing local signups API...${NC}"
test_api "Local Signups API" "http://localhost:3000/api/signups?env=local" "Local database not configured" "Returns setup message for local environment"

# Test 5: Production signups API (first-run experience)
echo -e "${YELLOW}☁️ Testing production signups API...${NC}"
test_api "Production Signups API" "http://localhost:3000/api/signups?env=prod" "Production database not configured" "Returns setup message for production environment"

# Test 6: Local signups export API (first-run experience)
echo -e "${YELLOW}📤 Testing local signups export API...${NC}"
test_api "Local Export API" "http://localhost:3000/api/signups/export?env=local&format=json" "Local database not configured" "Returns setup message for local export"

# Test 7: Production signups export API (first-run experience)
echo -e "${YELLOW}📤 Testing production signups export API...${NC}"
test_api "Production Export API" "http://localhost:3000/api/signups/export?env=prod&format=json" "Production database not configured" "Returns setup message for production export"

# Test 8: Waitlist signup API (first-run experience)
echo -e "${YELLOW}📝 Testing waitlist signup API...${NC}"
response=$(curl -s -X POST -H "Content-Type: application/json" -d '{"email":"test@example.com"}' "http://localhost:3000/api/waitlist" 2>/dev/null || echo "ERROR")
if echo "$response" | grep -q "Database not configured"; then
    print_result "Waitlist Signup API" "PASS" "Returns setup message for signup attempts"
else
    print_result "Waitlist Signup API" "FAIL" "Expected 'Database not configured' not found in response"
    echo "Response: $response"
fi

# Test 9: Check for new icons in dashboard
echo -e "${YELLOW}🎨 Testing updated icons...${NC}"
test_page "Wrench Icon" "http://localhost:3000/signups.html" "M11.42 15.17" "Wrench icon present in Run Setup button"
test_page "Database Icon" "http://localhost:3000/signups.html" "M4 7v10c0 2.21" "Database icon present for local environment"
test_page "Cloud Icon" "http://localhost:3000/signups.html" "M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999" "Cloud icon present for production environment"

# Test 10: Check for setup state text
echo -e "${YELLOW}📝 Testing setup state text...${NC}"
test_page "Setup Required Text" "http://localhost:3000/signups.html" "Setup Required" "Setup Required text present in dashboard"
test_page "Run Setup Button Text" "http://localhost:3000/signups.html" "Click the Run Setup button" "Updated instruction text present"

# Test 11: Check for disabled button logic
echo -e "${YELLOW}🔒 Testing disabled button logic...${NC}"
test_page "Disabled Button Logic" "http://localhost:3000/signups.html" "refreshLocalBtn.*disabled.*true" "Refresh button disabled for local environment"
test_page "Disabled Button Logic" "http://localhost:3000/signups.html" "refreshProdBtn.*disabled.*true" "Refresh button disabled for production environment"
test_page "Disabled Button Logic" "http://localhost:3000/signups.html" "nukeLocalBtn" "Nuke button present for local environment"
test_page "Disabled Button Logic" "http://localhost:3000/signups.html" "exportLocalBtn" "Export button present for local environment"
test_page "Disabled Button Logic" "http://localhost:3000/signups.html" "exportProdBtn" "Export button present for production environment"

# Test 12: Check for graceful error handling
echo -e "${YELLOW}🛡️ Testing graceful error handling...${NC}"
test_page "Error Handling" "http://localhost:3000/signups.html" "isSetupMessage" "Setup message detection logic present"
test_page "Error Handling" "http://localhost:3000/signups.html" "hsl(0_0%_8%)" "Default light background setup state styling present"

# Test 13: Check for setup function
echo -e "${YELLOW}⚙️ Testing setup function...${NC}"
test_page "Setup Function" "http://localhost:3000/signups.html" "function runSetup" "Setup function present"
test_page "Setup Function" "http://localhost:3000/signups.html" "localActionBtn.*addEventListener" "Local action button event listener present"
test_page "Setup Modal" "http://localhost:3000/signups.html" "setupModal.*modal-overlay" "Setup modal HTML present"
test_page "Setup Modal" "http://localhost:3000/signups.html" "Edit .env.local with your database credentials" "Accurate setup instructions present"

# Test 16: Check for Add User functionality
echo -e "${YELLOW}👤 Testing Add User functionality...${NC}"
test_page "Add User Modal" "http://localhost:3000/signups.html" "addUserModal.*modal-overlay" "Add User modal HTML present"
test_page "Add User Modal" "http://localhost:3000/signups.html" "Add Mock Users" "Add User modal title present"
test_page "Add User Modal" "http://localhost:3000/signups.html" "Number of users:" "Add User modal input present"
test_page "Add User Modal" "http://localhost:3000/signups.html" "addUsersBtn" "Add Users button present"
test_page "Add User Success Modal" "http://localhost:3000/signups.html" "addUserSuccessModal.*modal-overlay" "Add User success modal HTML present"
test_page "Add User Error Modal" "http://localhost:3000/signups.html" "addUserErrorModal.*modal-overlay" "Add User error modal HTML present"

# Test 17: Test Add User API
echo -e "${YELLOW}👤 Testing Add User API...${NC}"
response=$(curl -s -X POST "http://localhost:3000/api/signups/add-mock" -H "Content-Type: application/json" -d '{"count": 1}')
if echo "$response" | grep -q '"success":true'; then
    print_result "Add User API" "PASS" "Add User API successfully adds mock users"
else
    print_result "Add User API" "FAIL" "Add User API failed or returned unexpected response"
fi

# Test 18: Check for proper HTTP status codes
echo -e "${YELLOW}📊 Testing HTTP status codes...${NC}"
local_status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/signups?env=local")
if [ "$local_status" = "503" ]; then
    print_result "Local API Status Code" "PASS" "Returns 503 Service Unavailable for setup state"
else
    print_result "Local API Status Code" "FAIL" "Expected 503, got $local_status"
fi

prod_status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/signups?env=prod")
if [ "$prod_status" = "503" ]; then
    print_result "Production API Status Code" "PASS" "Returns 503 Service Unavailable for setup state"
else
    print_result "Production API Status Code" "FAIL" "Expected 503, got $prod_status"
fi

waitlist_status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/waitlist/stats")
if [ "$waitlist_status" = "200" ]; then
    print_result "Waitlist Stats Status Code" "PASS" "Returns 200 OK with setup message"
else
    print_result "Waitlist Stats Status Code" "FAIL" "Expected 200, got $waitlist_status"
fi

# Test 15: Check for CORS headers
echo -e "${YELLOW}🌐 Testing CORS headers...${NC}"
cors_headers=$(curl -s -I "http://localhost:3000/api/waitlist/stats" | grep -i "access-control-allow-origin" || echo "NOT_FOUND")
if echo "$cors_headers" | grep -q "\\*"; then
    print_result "CORS Headers" "PASS" "CORS headers properly set"
else
    print_result "CORS Headers" "FAIL" "CORS headers not found or incorrect"
fi

# Test 16: Check for security headers
echo -e "${YELLOW}🔒 Testing security headers...${NC}"
security_headers=$(curl -s -D - -X POST -H "Content-Type: application/json" -d '{"email":"test@example.com"}' "http://localhost:3000/api/waitlist" | grep -E "(X-Content-Type-Options|X-Frame-Options|X-XSS-Protection)" || echo "NOT_FOUND")
if echo "$security_headers" | grep -q "nosniff\|DENY\|1; mode=block"; then
    print_result "Security Headers" "PASS" "Security headers properly set"
else
    print_result "Security Headers" "FAIL" "Security headers not found or incorrect"
    echo "Headers found: $security_headers"
fi

# Test 17: Test setup script functionality
echo -e "${YELLOW}🔧 Testing setup script functionality...${NC}"

# Test setup script exists and is executable
if [ -f "./scripts/setup.sh" ] && [ -x "./scripts/setup.sh" ]; then
    print_result "Setup Script Exists" "PASS" "Setup script exists and is executable"
else
    print_result "Setup Script Exists" "FAIL" "Setup script missing or not executable"
fi

# Test setup script creates both files when both don't exist
if [ -f ".env.local" ] && [ -f ".env.prod" ]; then
    # Backup existing files
    cp .env.local .env.local.backup 2>/dev/null || true
    cp .env.prod .env.prod.backup 2>/dev/null || true
    
    # Remove existing files to test creation
    rm .env.local .env.prod 2>/dev/null || true
    
    # Test script with both files created
    output=$(echo "y" | echo "y" | ./scripts/setup.sh 2>/dev/null)
    if echo "$output" | grep -q "Edit .env.local with your local database credentials" && echo "$output" | grep -q "Edit .env.prod with your production database credentials"; then
        print_result "Setup Script Both Files" "PASS" "Setup script correctly shows both file creation steps"
    else
        print_result "Setup Script Both Files" "FAIL" "Setup script missing steps for both files"
    fi
    
    # Restore backup files
    mv .env.local.backup .env.local 2>/dev/null || true
    mv .env.prod.backup .env.prod 2>/dev/null || true
else
    print_result "Setup Script Both Files" "SKIP" "Cannot test - environment files don't exist"
fi

# Test setup script dynamic step numbering
output=$(echo "n" | echo "n" | ./scripts/setup.sh 2>/dev/null)
if echo "$output" | grep -q "1. Test your local setup:"; then
    print_result "Setup Script Dynamic Steps" "PASS" "Setup script correctly shows only test step when files skipped"
else
    print_result "Setup Script Dynamic Steps" "FAIL" "Setup script step numbering incorrect"
fi

echo ""
echo -e "${BLUE}📊 Test Results Summary${NC}"
echo "=========================="
echo -e "${GREEN}✅ Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}❌ Tests Failed: $TESTS_FAILED${NC}"
echo -e "${BLUE}📋 Total Tests: $((TESTS_PASSED + TESTS_FAILED))${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All tests passed! StealthList is working perfectly.${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}⚠️  Some tests failed. Please check the output above.${NC}"
    exit 1
fi 