# Test Implementation Guide

This guide explains how to test the Docker integration for WSO2 APIM Catalog module.

## Prerequisites

1. **Docker Desktop** must be running
   ```bash
   # Check if Docker is running
   docker ps
   ```

   If you see an error, start Docker Desktop:
   - **macOS**: Open Docker Desktop from Applications
   - **Linux**: `sudo systemctl start docker`

2. **Java 17** installed
   ```bash
   java -version
   ```

3. **Gradle** (via wrapper)
   ```bash
   ./gradlew --version
   ```

## Testing Methods

### Method 1: Quick Docker Test (Recommended First)

This tests just the Docker services without running full integration tests.

```bash
# Navigate to mock services directory
cd ballerina-tests/resources/mock-services

# Option A: Using the test script
./test-docker.sh

# Option B: Using Makefile
make quick    # Builds, starts, and tests
```

**What this does:**
- Builds the Docker image
- Starts all mock services
- Verifies all ports are listening
- Tests health endpoints
- Checks OAuth2 token generation

**Expected output:**
```
✓ Docker daemon is running
✓ Container started
✓ Container is running
✓ Health check endpoint (8080) - OK
✓ Port 8080 - Listening
✓ Port 8081 - Listening
...
✓ OAuth2 token endpoint - OK
```

### Method 2: Full Gradle Test Suite

This runs the complete integration test suite with automatic Docker management.

```bash
# From project root
./gradlew clean test

# Or test just the ballerina-tests module
./gradlew :wso2.apim.catalog-ballerina-tests:test

# With debug output
./gradlew :wso2.apim.catalog-ballerina-tests:test --info
```

**What this does:**
1. Builds the main module
2. Publishes test resource packages
3. Starts Docker containers (via `startMockServices`)
4. Runs all Ballerina tests
5. Stops Docker containers (via `stopMockServices`)
6. Commits dependency files

**Expected test cases:**
- `testSingleService` - Tests service catalog publishing (projects 0-8)
- `testSingleServiceWithConnectionRefuse` - Tests connection failures
- `testSingleServiceWithTokenCallfailure` - Tests OAuth2 token failures
- `testSingleUnauthorizedService` - Tests authorization errors
- `testSingleServiceWithBasepathAsSlash` - Tests root path handling

### Method 3: Manual Docker + Manual Tests

For debugging or development:

```bash
# 1. Start Docker services manually
cd ballerina-tests/resources/mock-services
docker compose up -d --build

# 2. Wait for services
sleep 15

# 3. Check status
docker ps --filter name=wso2-apim-mock-services
docker logs wso2-apim-mock-services

# 4. Run tests manually (from project root)
cd ../../..
./target/ballerina-runtime/bin/bal test -C ballerina-tests/

# 5. Stop services when done
cd ballerina-tests/resources/mock-services
docker compose down
```

### Method 4: Gradle Task by Task

Test individual Gradle tasks:

```bash
# Start services only
./gradlew :wso2.apim.catalog-ballerina-tests:startMockServices

# Verify they're running
docker ps
curl http://localhost:8080/health

# Stop services
./gradlew :wso2.apim.catalog-ballerina-tests:stopMockServices
```

## Makefile Commands

From `ballerina-tests/resources/mock-services/`:

```bash
make help       # Show all available commands
make build      # Build Docker image only
make start      # Start services
make stop       # Stop services
make restart    # Restart services
make logs       # View live logs
make test       # Run health tests
make status     # Show container status
make health     # Quick health check
make validate   # Validate Docker config
make clean      # Clean everything
make quick      # Build + start + test
```

## Troubleshooting

### Docker Daemon Not Running

**Error:**
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Solution:**
```bash
# macOS
open -a Docker

# Linux
sudo systemctl start docker

# Verify
docker ps
```

### Port Already in Use

**Error:**
```
Error starting userland proxy: listen tcp4 0.0.0.0:8080: bind: address already in use
```

**Solution:**
```bash
# Find what's using the port
lsof -i :8080

# Kill the process or stop the service
kill -9 <PID>

# Or change port in compose.yml
```

### Container Build Fails

**Error:**
```
failed to solve: failed to compute cache key
```

**Solution:**
```bash
# Clean Docker cache
docker system prune -a

# Rebuild from scratch
cd ballerina-tests/resources/mock-services
docker compose build --no-cache
```

### Services Not Responding

**Issue:** Container starts but services don't respond

**Debug:**
```bash
# Check container logs
docker logs wso2-apim-mock-services

# Check if Ballerina started
docker logs wso2-apim-mock-services 2>&1 | grep "started"

# Execute shell in container
docker exec -it wso2-apim-mock-services /bin/bash

# Inside container, check processes
ps aux | grep bal

# Check if ports are bound inside container
netstat -tulpn | grep LISTEN
```

### Tests Fail

**Issue:** Tests fail even though Docker is running

**Debug:**
```bash
# Check if all ports are accessible
for port in 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 8090 8092 9444 9441; do
  nc -zv localhost $port
done

# Check test logs
cat ballerina-tests/target/test_results.json

# Run tests with debug
./gradlew :wso2.apim.catalog-ballerina-tests:test --debug

# Check test artifacts
docker exec wso2-apim-mock-services ls -la /tmp/artifacts/
```

### SSL/TLS Errors

**Issue:** OAuth2 token endpoint fails with SSL errors

**Debug:**
```bash
# Test with curl (ignoring SSL)
curl -k -v https://localhost:9444/oauth2/token -X POST

# Check keystore in container
docker exec wso2-apim-mock-services ls -la /app/resources/

# Verify keystore is readable
docker exec wso2-apim-mock-services cat /app/resources/ballerinaKeystore.p12 > /dev/null && echo "OK" || echo "FAIL"
```

## Verification Checklist

Before running full tests, verify:

- [ ] Docker Desktop is running
- [ ] No port conflicts (8080-8092, 9444, 9441)
- [ ] Docker image builds successfully
- [ ] Container starts without errors
- [ ] Health endpoint responds (http://localhost:8080/health)
- [ ] All ports are listening
- [ ] OAuth2 endpoint returns token (https://localhost:9444/oauth2/token)
- [ ] Gradle can find Docker

## Test Artifacts

After running tests, check:

```bash
# Inside container
docker exec wso2-apim-mock-services ls -la /tmp/artifacts/

# Example artifacts
/tmp/artifacts/artifacts_0.json  # From test project 0
/tmp/artifacts/artifacts_1.json  # From test project 1
...

# Copy artifacts to host
docker cp wso2-apim-mock-services:/tmp/artifacts ./test-artifacts/
```

## Performance Notes

- **First build**: ~2-5 minutes (downloads Ballerina base image)
- **Subsequent builds**: ~30 seconds (uses cache)
- **Container startup**: ~10-15 seconds
- **Full test suite**: ~2-3 minutes

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Start Docker
  run: docker version

- name: Run tests
  run: ./gradlew clean test

- name: Upload test results
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: test-results
    path: ballerina-tests/target/test_results.json
```

### Local CI Simulation

```bash
# Simulate CI environment
./gradlew clean
./gradlew test --no-daemon
```

## Quick Start for New Developers

```bash
# 1. Clone and setup
git clone <repo>
cd module-ballerinax-wso2.apim.catalog

# 2. Ensure Docker is running
docker ps

# 3. Run quick test
cd ballerina-tests/resources/mock-services
make quick

# 4. If that works, run full suite
cd ../../..
./gradlew clean test
```

## Success Indicators

**Docker Test Success:**
```
✓ Docker daemon is running
✓ Container started
✓ Health check endpoint (8080) - OK
✓ All ports listening
✓ OAuth2 token endpoint - OK
```

**Gradle Test Success:**
```
Starting Mock APIM mock services...
Mock services are ready
Running tests...
BUILD SUCCESSFUL
Mock services stopped
```

**Test Output Example:**
```
Compiling source
    ballerinax/wso2.apim.catalog-ballerina-tests:0.1.0

Running Tests
    testSingleService               PASSED
    testSingleServiceWithConnectionRefuse  PASSED
    testSingleServiceWithTokenCallfailure  PASSED
    testSingleUnauthorizedService   PASSED

    11 passing
    0 failing
    0 skipped
```

## Next Steps After Successful Tests

1. **Commit changes** (if everything passes)
2. **Create PR** with test results
3. **Update CI/CD** configuration if needed
4. **Document** any environment-specific notes

## Getting Help

If tests still fail after following this guide:

1. Collect debug information:
   ```bash
   ./gradlew :wso2.apim.catalog-ballerina-tests:test --info > test-debug.log 2>&1
   docker logs wso2-apim-mock-services > docker-debug.log 2>&1
   ```

2. Check the detailed logs in:
   - `test-debug.log`
   - `docker-debug.log`
   - `ballerina-tests/target/`

3. Common issues documented in DOCKER_INTEGRATION.md
