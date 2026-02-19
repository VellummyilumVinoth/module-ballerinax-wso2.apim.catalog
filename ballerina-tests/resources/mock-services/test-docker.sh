#!/bin/bash
# Test script for Docker mock services

set -e

echo "=================================="
echo "WSO2 APIM Mock Services Test"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

# Check if Docker is running
echo "Checking Docker daemon..."
if ! docker ps >/dev/null 2>&1; then
    echo -e "${RED}✗ Docker daemon is not running${NC}"
    echo ""
    echo "Please start Docker Desktop and try again:"
    echo "  - macOS: Open Docker Desktop from Applications"
    echo "  - Linux: sudo systemctl start docker"
    echo ""
    exit 1
fi
print_status 0 "Docker daemon is running"
echo ""

# Build and start containers
echo "Building and starting containers..."
docker compose up -d --build
print_status $? "Container started"
echo ""

# Wait for services to be ready
echo "Waiting for services to initialize (15 seconds)..."
sleep 15
echo ""

# Check container status
echo "Checking container status..."
CONTAINER_STATUS=$(docker ps --filter name=wso2-apim-mock-services --format "{{.Status}}")
if [ -n "$CONTAINER_STATUS" ]; then
    print_status 0 "Container is running: $CONTAINER_STATUS"
else
    print_status 1 "Container is not running"
    echo ""
    echo "Container logs:"
    docker logs wso2-apim-mock-services 2>&1 | tail -20
    exit 1
fi
echo ""

# Test health endpoint
echo "Testing service endpoints..."
if curl -f -s http://localhost:8080/health > /dev/null; then
    print_status 0 "Health check endpoint (8080) - OK"
else
    print_status 1 "Health check endpoint (8080) - FAILED"
fi

# Test API Manager services
for port in 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 8090 8092; do
    if nc -z localhost $port 2>/dev/null; then
        print_status 0 "Port $port - Listening"
    else
        print_status 1 "Port $port - Not listening"
    fi
done

# Test OAuth2 services (HTTPS)
for port in 9444 9441; do
    if nc -z localhost $port 2>/dev/null; then
        print_status 0 "Port $port (HTTPS) - Listening"
    else
        print_status 1 "Port $port (HTTPS) - Not listening"
    fi
done
echo ""

# Test OAuth2 token endpoint
echo "Testing OAuth2 token endpoint..."
TOKEN_RESPONSE=$(curl -k -s -X POST https://localhost:9444/oauth2/token 2>&1)
if echo "$TOKEN_RESPONSE" | grep -q "access_token"; then
    print_status 0 "OAuth2 token endpoint - OK"
    echo "   Token: $(echo $TOKEN_RESPONSE | jq -r '.access_token' 2>/dev/null || echo 'Response received')"
else
    print_status 1 "OAuth2 token endpoint - FAILED"
    echo "   Response: $TOKEN_RESPONSE"
fi
echo ""

# Show container logs
echo "Recent container logs:"
echo "-----------------------------------"
docker logs wso2-apim-mock-services 2>&1 | tail -30
echo "-----------------------------------"
echo ""

echo -e "${GREEN}=================================="
echo "Test Complete!"
echo "==================================${NC}"
echo ""
echo "To view logs: docker logs wso2-apim-mock-services"
echo "To stop:      docker compose down"
echo "To restart:   docker compose restart"
echo ""
