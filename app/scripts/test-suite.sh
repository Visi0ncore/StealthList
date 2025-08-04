#!/bin/bash

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

# Function to cleanup test data
cleanup_test_data() {
    echo -e "${YELLOW}🧹 Cleaning up test data...${NC}"
    
    # Clean up local environment if configured
    if [ "$LOCAL_CONFIGURED" = true ]; then
        local cleanup_response=$(curl -s -X DELETE "http://localhost:3000/api/signups?env=local")
        if echo "$cleanup_response" | grep -q '"success":true'; then
            echo -e "${GREEN}✅ Local environment cleaned up${NC}"
        else
            echo -e "${YELLOW}⚠️  Local environment cleanup failed or not needed${NC}"
        fi
    fi
    
    # SAFETY: We NEVER clean up production data as it's real data
    echo -e "${RED}🚨 SAFETY: Production environment contains real data - NEVER deleted${NC}"
    echo -e "${BLUE}ℹ️  Production environment left unchanged (real data preserved)${NC}"
}

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

# Function to run tests for unconfigured environments
run_unconfigured_tests() {
    echo -e "${YELLOW}🧪 Running tests for UNCONFIGURED environments...${NC}"
    
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
}

# Function to run tests for configured environments
run_configured_tests() {
    echo -e "${YELLOW}🧪 Running tests for CONFIGURED environments...${NC}"
    
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
    
    # Test 4: Waitlist stats API (should return data)
    echo -e "${YELLOW}📈 Testing waitlist stats API...${NC}"
    local stats_response=$(curl -s "http://localhost:3000/api/waitlist/stats")
    if echo "$stats_response" | grep -q '"count"'; then
        print_result "Waitlist Stats API" "PASS" "Waitlist stats API returns data"
    else
        print_result "Waitlist Stats API" "FAIL" "Waitlist stats API failed (Response: $stats_response)"
    fi
    
    # Test 5: Local signups API (if configured)
    if [ "$LOCAL_CONFIGURED" = true ]; then
        echo -e "${YELLOW}🏠 Testing local signups API...${NC}"
        local local_response=$(curl -s "http://localhost:3000/api/signups?env=local")
        if echo "$local_response" | grep -q '"environment":"local"'; then
            print_result "Local Signups API" "PASS" "Local signups API returns data"
        else
            print_result "Local Signups API" "FAIL" "Local signups API failed (Response: $local_response)"
        fi
        
        # Test 6: Local export API
        echo -e "${YELLOW}📤 Testing local signups export API...${NC}"
        local export_response=$(curl -s "http://localhost:3000/api/signups/export?env=local")
        if echo "$export_response" | grep -q '"environment":"local"' || echo "$export_response" | grep -q "ID,Email,Signup Date"; then
            print_result "Local Export API" "PASS" "Local export API returns data"
        else
            print_result "Local Export API" "FAIL" "Local export API failed (Response: $export_response)"
        fi
        
        # Test 7: Add User API
        echo -e "${YELLOW}👤 Testing Add User API...${NC}"
        local add_user_response=$(curl -s -X POST "http://localhost:3000/api/signups/add-mock" -H "Content-Type: application/json" -d '{"count": 1}')
        if echo "$add_user_response" | grep -q '"success":true'; then
            print_result "Add User API" "PASS" "Add User API successfully adds mock users"
            # Clean up the test user we just created
            local cleanup_response=$(curl -s -X DELETE "http://localhost:3000/api/signups?env=local")
            if echo "$cleanup_response" | grep -q '"success":true'; then
                echo -e "${GREEN}✅ Test user cleaned up${NC}"
            fi
        else
            print_result "Add User API" "FAIL" "Add User API failed (Response: $add_user_response)"
        fi
        
        # Test 8: UI elements for configured local environment
        echo -e "${YELLOW}🎨 Testing UI elements for configured local environment...${NC}"
        test_page "Add Users Button" "http://localhost:3000/signups.html" "Add Users" "Add Users button text present"
        test_page "Add User Modal" "http://localhost:3000/signups.html" "addUserModal.*modal-overlay" "Add User modal HTML present"
        test_page "Add User Modal Title" "http://localhost:3000/signups.html" "Add Mock Users" "Add User modal title present"
        
        # Test 9: Button states for configured local environment
        echo -e "${YELLOW}🔒 Testing button states for configured local environment...${NC}"
        test_page "Enabled Buttons" "http://localhost:3000/signups.html" "refreshLocalBtn" "Refresh button present for local environment"
        test_page "Enabled Buttons" "http://localhost:3000/signups.html" "exportLocalBtn" "Export button present for local environment"
        test_page "Enabled Buttons" "http://localhost:3000/signups.html" "nukeLocalBtn" "Nuke button present for local environment"
        
        # Test 10: HTTP status codes for configured local environment
        echo -e "${YELLOW}📊 Testing HTTP status codes for configured local environment...${NC}"
        test_api_status "Local API Status Code" "http://localhost:3000/api/signups?env=local" "200" "Local API returns 200 OK"
    else
        echo -e "${YELLOW}🏠 Skipping local environment tests (not configured)...${NC}"
        print_result "Local Environment" "SKIP" "Local environment not configured"
    fi
    
    # Test 11: Production signups API (if configured)
    if [ "$PROD_CONFIGURED" = true ]; then
        echo -e "${YELLOW}☁️ Testing production signups API...${NC}"
        local prod_response=$(curl -s "http://localhost:3000/api/signups?env=prod")
        if echo "$prod_response" | grep -q '"environment":"prod"'; then
            print_result "Production Signups API" "PASS" "Production signups API returns data"
        else
            print_result "Production Signups API" "FAIL" "Production signups API failed (Response: $prod_response)"
        fi
        
        # Test 12: Production export API
        echo -e "${YELLOW}📤 Testing production signups export API...${NC}"
        local export_response=$(curl -s "http://localhost:3000/api/signups/export?env=prod")
        if echo "$export_response" | grep -q '"environment":"prod"' || echo "$export_response" | grep -q "ID,Email,Signup Date"; then
            print_result "Production Export API" "PASS" "Production export API returns data"
        else
            print_result "Production Export API" "FAIL" "Production export API failed (Response: $export_response)"
        fi
        
        # Test 13: Button states for configured production environment
        echo -e "${YELLOW}🔒 Testing button states for configured production environment...${NC}"
        test_page "Enabled Buttons" "http://localhost:3000/signups.html" "refreshProdBtn" "Refresh button present for production environment"
        test_page "Enabled Buttons" "http://localhost:3000/signups.html" "exportProdBtn" "Export button present for production environment"
        
        # Test 14: HTTP status codes for configured production environment
        echo -e "${YELLOW}📊 Testing HTTP status codes for configured production environment...${NC}"
        test_api_status "Production API Status Code" "http://localhost:3000/api/signups?env=prod" "200" "Production API returns 200 OK"
    else
        echo -e "${YELLOW}☁️ Skipping production environment tests (not configured)...${NC}"
        print_result "Production Environment" "SKIP" "Production environment not configured"
    fi
    
    # Test 15: Waitlist signup API (should work if any environment is configured)
    echo -e "${YELLOW}📝 Testing waitlist signup API...${NC}"
    local waitlist_response=$(curl -s -X POST "http://localhost:3000/api/waitlist" -H "Content-Type: application/json" -d '{"email":"test@example.com"}')
    if echo "$waitlist_response" | grep -q '"success"'; then
        print_result "Waitlist Signup API" "PASS" "Waitlist signup API works"
        # Clean up the test signup we just created (if local environment is configured)
        if [ "$LOCAL_CONFIGURED" = true ]; then
            local cleanup_response=$(curl -s -X DELETE "http://localhost:3000/api/signups?env=local")
            if echo "$cleanup_response" | grep -q '"success":true'; then
                echo -e "${GREEN}✅ Test signup cleaned up${NC}"
            fi
        fi
    else
        print_result "Waitlist Signup API" "FAIL" "Waitlist signup API failed (Response: $waitlist_response)"
    fi
    
    # Test 16: Common UI elements
    echo -e "${YELLOW}🎨 Testing common UI elements...${NC}"
    test_page "Wrench Icon" "http://localhost:3000/signups.html" "M11.42 15.17" "Wrench icon present in Run Setup button"
    test_page "Database Icon" "http://localhost:3000/signups.html" "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7" "Database icon present for local environment"
    test_page "Cloud Icon" "http://localhost:3000/signups.html" "M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999" "Cloud icon present for production environment"
    
    # Test 17: CORS and security headers
    echo -e "${YELLOW}🌐 Testing CORS headers...${NC}"
    local cors_headers=$(curl -s -I "http://localhost:3000/api/signups?env=local" | grep -i "access-control-allow-origin")
    if [ -n "$cors_headers" ]; then
        print_result "CORS Headers" "PASS" "CORS headers properly set"
    else
        print_result "CORS Headers" "FAIL" "CORS headers not found"
    fi
    
    echo -e "${YELLOW}🔒 Testing security headers...${NC}"
    local security_headers=$(curl -s -I "http://localhost:3000/api/signups?env=local" | grep -E "(X-Content-Type-Options|X-Frame-Options|X-XSS-Protection)")
    if [ -n "$security_headers" ]; then
        print_result "Security Headers" "PASS" "Security headers properly set"
    else
        print_result "Security Headers" "FAIL" "Security headers not found"
    fi
}

# Main test execution
echo -e "${BLUE}🧪 StealthList Test Suite${NC}"
echo -e "${BLUE}==================================${NC}"
echo ""

# Detect environment configuration
detect_environment

# Determine which test suite to run
if [ "$LOCAL_CONFIGURED" = false ] && [ "$PROD_CONFIGURED" = false ]; then
    echo -e "${YELLOW}🔧 Both environments are UNCONFIGURED - running unconfigured tests${NC}"
    echo ""
    run_unconfigured_tests
elif [ "$LOCAL_CONFIGURED" = true ] && [ "$PROD_CONFIGURED" = false ]; then
    echo -e "${YELLOW}🏠 Local CONFIGURED, Production UNCONFIGURED - running mixed tests${NC}"
    echo ""
    run_configured_tests
elif [ "$LOCAL_CONFIGURED" = false ] && [ "$PROD_CONFIGURED" = true ]; then
    echo -e "${YELLOW}☁️ Local UNCONFIGURED, Production CONFIGURED - running mixed tests${NC}"
    echo ""
    run_configured_tests
elif [ "$LOCAL_CONFIGURED" = true ] && [ "$PROD_CONFIGURED" = true ]; then
    echo -e "${YELLOW}✅ Both environments are CONFIGURED - running configured tests${NC}"
    echo ""
    run_configured_tests
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