#!/bin/bash
# Validation script for Docker setup (works without Docker running)

set -e

echo "=================================="
echo "WSO2 APIM Docker Setup Validation"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass_count=0
fail_count=0

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((pass_count++))
    else
        echo -e "${RED}✗${NC} $2 (missing: $1)"
        ((fail_count++))
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((pass_count++))
    else
        echo -e "${RED}✗${NC} $2 (missing: $1)"
        ((fail_count++))
    fi
}

# Function to validate content
check_content() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $3"
        ((pass_count++))
    else
        echo -e "${RED}✗${NC} $3"
        ((fail_count++))
    fi
}

echo "Checking Docker configuration files..."
check_file "compose.yml" "Docker Compose file"
check_file "Dockerfile" "Dockerfile"
check_file ".dockerignore" "Docker ignore file"
echo ""

echo "Checking Ballerina service files..."
check_file "Ballerina.toml" "Ballerina project config"
check_file "service.bal" "API Manager services"
check_file "token_service.bal" "OAuth2 token services"
check_file "types.bal" "Type definitions"
check_file "utils.bal" "Utility functions"
echo ""

echo "Checking resources..."
check_dir "resources" "Resources directory"
check_file "resources/ballerinaKeystore.p12" "Ballerina keystore"
check_file "resources/ballerinaTruststore.p12" "Ballerina truststore"
check_file "resources/clientKeyStore.p12" "Client keystore"
check_file "resources/clientTrustStore.p12" "Client truststore"
echo ""

echo "Validating Docker Compose configuration..."
if command -v docker >/dev/null 2>&1; then
    if docker compose config >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Docker Compose syntax is valid"
        ((pass_count++))
    else
        echo -e "${RED}✗${NC} Docker Compose syntax error"
        ((fail_count++))
    fi
else
    echo -e "${YELLOW}!${NC} Docker not found, skipping syntax check"
fi
echo ""

echo "Checking service implementations..."
check_content "service.bal" "8080" "Service on port 8080"
check_content "service.bal" "8089" "Service on port 8089 (connection test)"
check_content "service.bal" "8090" "Service on port 8090 (unauthorized test)"
check_content "token_service.bal" "9444" "OAuth2 service on port 9444"
check_content "token_service.bal" "9441" "OAuth2 failure service on port 9441"
echo ""

echo "Checking Docker Compose ports..."
check_content "compose.yml" "8080:8080" "Port mapping 8080"
check_content "compose.yml" "9444:9444" "Port mapping 9444"
check_content "compose.yml" "9441:9441" "Port mapping 9441"
check_content "compose.yml" "healthcheck" "Health check configured"
echo ""

echo "Checking Gradle integration..."
BUILD_GRADLE="../../../build.gradle"
if [ -f "$BUILD_GRADLE" ]; then
    check_content "$BUILD_GRADLE" "startMockServices" "startMockServices task"
    check_content "$BUILD_GRADLE" "stopMockServices" "stopMockServices task"
    check_content "$BUILD_GRADLE" "docker compose" "Docker Compose commands"
else
    echo -e "${YELLOW}!${NC} build.gradle not found at expected location"
fi
echo ""

echo "Checking test configurations..."
for i in 0 1 2 3 4 5 6 7 8 9 10 11; do
    CONFIG_FILE="../../tests/configs/sample_project_${i}/Config.toml"
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${GREEN}✓${NC} Config for sample_project_${i}"
        ((pass_count++))
    else
        echo -e "${RED}✗${NC} Config for sample_project_${i} (missing: $CONFIG_FILE)"
        ((fail_count++))
    fi
done
echo ""

echo "Checking special test configurations..."
check_content "../../tests/configs/sample_project_9/Config.toml" "8089" "sample_project_9 uses port 8089"
check_content "../../tests/configs/sample_project_11/Config.toml" "8090" "sample_project_11 uses port 8090"
check_content "../../tests/configs/sample_project_10/Config.toml" "9441" "sample_project_10 uses port 9441"
echo ""

echo "Checking documentation..."
check_file "README.md" "Docker setup README"
check_file "../../../TEST_GUIDE.md" "Test guide"
check_file "../../../DOCKER_INTEGRATION.md" "Docker integration docs"
echo ""

echo "Checking helper scripts..."
check_file "test-docker.sh" "Docker test script"
check_file "Makefile" "Makefile"
check_file "validate-setup.sh" "This validation script"
echo ""

# Summary
echo "=================================="
echo "Validation Summary"
echo "=================================="
echo -e "Passed: ${GREEN}$pass_count${NC}"
echo -e "Failed: ${RED}$fail_count${NC}"
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Start Docker Desktop"
    echo "  2. Run: ./test-docker.sh"
    echo "  3. Or run: make quick"
    echo "  4. Or run full tests: cd ../../.. && ./gradlew clean test"
    exit 0
else
    echo -e "${RED}✗ Some validations failed${NC}"
    echo ""
    echo "Please fix the issues above before proceeding."
    exit 1
fi
