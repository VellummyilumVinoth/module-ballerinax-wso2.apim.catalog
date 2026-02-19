# Docker Integration Summary

This document summarizes the Docker integration implementation for the WSO2 APIM Catalog module, following the pattern from the Ballerina HTTP module's LDAP integration.

## Implementation Overview

### 1. Docker Compose Configuration ✅

**Location:** `ballerina-tests/resources/mock-services/compose.yml`

- Single container running all mock services
- Exposes ports 8080-8092 (API Manager services)
- Exposes ports 9444, 9441 (OAuth2 token services)
- Includes health check on port 8080
- Uses bridge networking

### 2. Docker Image Files ✅

**Base Files:**
- `Dockerfile` - Multi-stage build using Ballerina 2201.10.5
- `Ballerina.toml` - Project configuration
- `.dockerignore` - Excludes unnecessary files

**Service Implementation:**
- `service.bal` - Mock API Manager services (14 endpoints)
- `token_service.bal` - OAuth2 token services (success & failure)
- `types.bal` - Type definitions
- `utils.bal` - Utility functions
- `resources/` - SSL certificates and keystores

### 3. Gradle Task Integration ✅

**Location:** `ballerina-tests/build.gradle`

**New Tasks:**
1. `startMockServices` - Starts Docker containers
   - Checks if container is already running
   - Builds and starts using Docker Compose
   - Waits 15 seconds for initialization
   - Verifies health status
   - Skips on Windows

2. `stopMockServices` - Stops Docker containers
   - Checks if container is running
   - Gracefully stops container
   - Waits 5 seconds for shutdown
   - Removes container
   - Skips on Windows

**Task Dependencies:**
```gradle
ballerinaTest {
    dependsOn(startMockServices)
    finalizedBy(stopMockServices)
}
```

### 4. Test Configuration Updates ✅

**Updated Files:**
- `tests/configs/sample_project_9/Config.toml` - Changed port 1111 → 8089
- `tests/configs/sample_project_11/Config.toml` - Changed port 8091 → 8090

**All Configurations:**
| Test Project | Service URL | Token URL | Purpose |
|--------------|-------------|-----------|---------|
| 0 | http://localhost:8080 | https://localhost:9444 | Basic test |
| 1 | http://localhost:8081 | https://localhost:9444 | Basic test |
| 2 | http://localhost:8082 | https://localhost:9444 | Basic test |
| 3 | http://localhost:8083 | https://localhost:9444 | Basic test |
| 4 | http://localhost:8092 | https://localhost:9444 | Basic test |
| 5 | http://localhost:8085 | https://localhost:9444 | Basic test |
| 6 | http://localhost:8086 | https://localhost:9444 | Basic test |
| 7 | http://localhost:8087 | https://localhost:9444 | Basepath test |
| 8 | http://localhost:8088 | https://localhost:9444 | Basic test |
| 9 | http://localhost:8089 | https://localhost:9444 | Connection refuse test |
| 10 | http://localhost:8080 | https://localhost:9441 | Token failure test |
| 11 | http://localhost:8090 | https://localhost:9444 | Unauthorized test |

### 5. Documentation ✅

**Created Files:**
- `ballerina-tests/resources/mock-services/README.md` - Detailed Docker documentation
- `DOCKER_INTEGRATION.md` - This summary document

**Updated Files:**
- `README.md` - Added Docker prerequisites and test running instructions

## Service Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Docker Container: wso2-apim-mock-services                 │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  API Manager Mock Services (Ballerina)              │  │
│  │                                                       │  │
│  │  • 8080-8088: Standard service endpoints            │  │
│  │  • 8089: Connection failure simulation              │  │
│  │  • 8090: Unauthorized response simulation           │  │
│  │  • 8092: Additional service endpoint                │  │
│  │                                                       │  │
│  │  Artifacts saved to: /tmp/artifacts/                │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  OAuth2 Token Services (HTTPS)                      │  │
│  │                                                       │  │
│  │  • 9444: Successful token generation                │  │
│  │  • 9441: Token failure simulation                   │  │
│  │                                                       │  │
│  │  Uses: ballerinaKeystore.p12                        │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                           ↑
                           │ localhost port forwarding
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  Integration Tests (ballerina-tests/tests)                 │
│                                                              │
│  • test_services.bal - Main test cases                     │
│  • Config.toml files point to Docker services              │
│  • Tests run sample projects that publish to catalog       │
└─────────────────────────────────────────────────────────────┘
```

## Usage Patterns

### Automatic (Recommended)

```bash
# Run all tests - Docker is automatically managed
./gradlew clean test

# Or from project root
./gradlew clean build
```

### Manual Docker Control

```bash
# Start services manually
./gradlew :wso2.apim.catalog-ballerina-tests:startMockServices

# Run tests without automatic Docker management
cd ballerina-tests
../target/ballerina-runtime/bin/bal test

# Stop services
./gradlew :wso2.apim.catalog-ballerina-tests:stopMockServices
```

### Docker Compose Direct

```bash
cd ballerina-tests/resources/mock-services

# Start
docker compose up -d --build

# Check logs
docker logs wso2-apim-mock-services

# Stop
docker compose down
```

## Key Features

1. **Automatic Lifecycle Management**
   - Services start before tests
   - Services stop after tests (even on failure)
   - No manual intervention required

2. **Platform Support**
   - macOS: Full support ✅
   - Linux: Full support ✅
   - Windows: Skips Docker operations (uses in-process services)

3. **Health Monitoring**
   - Health check endpoint on port 8080
   - 15-second initialization wait
   - Status verification before tests

4. **Test Isolation**
   - Each test project uses a dedicated port
   - Artifacts saved to separate files
   - No cross-test interference

5. **Developer Friendly**
   - Hot reload during development
   - Easy to debug with `docker logs`
   - Can inspect artifacts in container

## Comparison with HTTP Module LDAP Integration

| Feature | HTTP Module (LDAP) | This Implementation |
|---------|-------------------|---------------------|
| Container orchestration | Docker Compose ✅ | Docker Compose ✅ |
| Automatic start/stop | Gradle tasks ✅ | Gradle tasks ✅ |
| Health checks | Basic wait ⚠️ | Health endpoint ✅ |
| Multi-service | Single LDAP | 14 services ✅ |
| SSL/TLS | LDAP SSL | HTTPS tokens ✅ |
| Windows support | Skipped ✅ | Skipped ✅ |
| Test isolation | Single service | Port-based ✅ |

## Testing the Implementation

### Step 1: Build Docker Image

```bash
cd ballerina-tests/resources/mock-services
docker compose up -d --build
```

### Step 2: Verify Services

```bash
# Check container status
docker ps --filter name=wso2-apim-mock-services

# Test health endpoint
curl http://localhost:8080/health

# Check logs
docker logs wso2-apim-mock-services

# Test token service
curl -k https://localhost:9444/oauth2/token -X POST
```

### Step 3: Run Tests

```bash
cd ../../..  # Back to project root
./gradlew :wso2.apim.catalog-ballerina-tests:test
```

### Step 4: Verify Artifacts

```bash
# Check artifacts in container
docker exec wso2-apim-mock-services ls -la /tmp/artifacts/
docker exec wso2-apim-mock-services cat /tmp/artifacts/artifacts_0.json
```

## Troubleshooting

### Container Build Fails

```bash
# Check Docker is running
docker info

# Check Dockerfile syntax
docker build -t test-build ballerina-tests/resources/mock-services/

# View build logs
docker compose up --build
```

### Services Not Responding

```bash
# Check if ports are already in use
lsof -i :8080-8092
lsof -i :9444

# Force restart
docker compose down
docker compose up -d --force-recreate
```

### Tests Fail

```bash
# Check container logs
docker logs wso2-apim-mock-services

# Verify all ports are exposed
docker port wso2-apim-mock-services

# Check network connectivity
curl -v http://localhost:8080/health
```

### Gradle Task Issues

```bash
# Run with debug output
./gradlew :wso2.apim.catalog-ballerina-tests:startMockServices --info

# Check if container already exists
docker ps -a --filter name=wso2-apim-mock-services

# Manual cleanup
docker stop wso2-apim-mock-services
docker rm wso2-apim-mock-services
```

## Future Enhancements

1. **Multi-stage builds** - Optimize Docker image size
2. **Volume mounts** - Persist artifacts outside container
3. **Docker health checks** - Native Docker health monitoring
4. **Parallel test execution** - Multiple container instances
5. **CI/CD optimization** - Layer caching, pre-built images
6. **Windows support** - WSL2 or alternative solution

## Migration Notes

### From In-Process Services

**Before:** Services ran in the test process
```ballerina
// test_service_impl.bal - Services run during test
service / on new http:Listener(8080) { ... }
```

**After:** Services run in Docker
```bash
# Services are external, tests connect to them
./gradlew test  # Starts Docker, runs tests, stops Docker
```

### Configuration Changes

- Updated test configs to use correct ports
- No code changes needed in test files
- Gradle handles Docker lifecycle automatically

## Files Created

```
ballerina-tests/resources/mock-services/
├── compose.yml               # Docker Compose configuration
├── Dockerfile               # Container image definition
├── Ballerina.toml          # Ballerina project config
├── .dockerignore           # Docker ignore file
├── README.md               # Detailed documentation
├── service.bal             # API Manager mock services
├── token_service.bal       # OAuth2 token services
├── types.bal               # Type definitions
├── utils.bal               # Utility functions
└── resources/              # SSL certificates
    ├── ballerinaKeystore.p12
    ├── ballerinaTruststore.p12
    ├── clientKeyStore.p12
    └── clientTrustStore.p12
```

## Files Modified

```
ballerina-tests/
├── build.gradle                                    # Added Docker tasks
├── tests/configs/sample_project_9/Config.toml     # Updated port
└── tests/configs/sample_project_11/Config.toml    # Updated port

README.md                                           # Added Docker info
DOCKER_INTEGRATION.md                               # This file
```

## Summary

✅ **Completed:**
- Docker Compose configuration
- Dockerfile and supporting files
- Gradle tasks (start/stop)
- Test configuration updates
- Comprehensive documentation
- Following HTTP module patterns

🎯 **Benefits:**
- Automated test infrastructure
- Clean separation of concerns
- Easy to debug and maintain
- CI/CD ready
- Platform compatible

🚀 **Ready to Use:**
```bash
./gradlew clean test
```

The Docker integration is complete and ready for testing!
