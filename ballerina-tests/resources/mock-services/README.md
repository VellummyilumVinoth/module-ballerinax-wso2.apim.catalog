# WSO2 APIM Catalog Mock Services - Docker Setup

This directory contains the Docker configuration for running mock WSO2 API Manager services used in integration tests.

## Overview

The Docker setup provides containerized mock services that simulate:
- WSO2 API Manager Service Catalog endpoints (ports 8080-8092)
- OAuth2 Token Service (HTTPS port 9444)
- Token failure endpoint (HTTPS port 9441)
- Connection failure simulation (port 8089)
- Unauthorized response simulation (port 8090)

## Architecture

```
┌─────────────────────────────────────────┐
│  Docker Container                       │
│  wso2-apim-mock-services               │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ API Manager Mock Services       │   │
│  │ - Ports 8080-8092              │   │
│  │ - Accept service registrations  │   │
│  │ - Save artifacts to /tmp        │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ OAuth2 Token Services           │   │
│  │ - Port 9444 (HTTPS) - Success  │   │
│  │ - Port 9441 (HTTPS) - Failure  │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
         ↑
         │ Tests connect to localhost:808X
         │
┌─────────────────────────────────────────┐
│  Integration Tests                      │
│  (ballerina-tests/tests)               │
└─────────────────────────────────────────┘
```

## Service Port Mapping

| Port | Purpose | Test Project |
|------|---------|-------------|
| 8080 | Mock APIM Service | sample_project_0, 10 |
| 8081 | Mock APIM Service | sample_project_1 |
| 8082 | Mock APIM Service | sample_project_2 |
| 8083 | Mock APIM Service | sample_project_3 |
| 8084 | Mock APIM Service | sample_project_4 (artifacts_8) |
| 8085 | Mock APIM Service | sample_project_5 |
| 8086 | Mock APIM Service | sample_project_6 |
| 8087 | Mock APIM Service | sample_project_7 |
| 8088 | Mock APIM Service | sample_project_8 |
| 8089 | Connection failure test | sample_project_9 |
| 8090 | Unauthorized test | sample_project_11 |
| 9444 | OAuth2 Token (HTTPS) | All projects (default) |
| 9441 | Token failure (HTTPS) | sample_project_10 |

## Files

- **compose.yml** - Docker Compose configuration
- **Dockerfile** - Container image definition
- **service.bal** - Mock API Manager service implementations
- **token_service.bal** - OAuth2 token service implementations
- **types.bal** - Type definitions
- **utils.bal** - Utility functions
- **Ballerina.toml** - Ballerina project configuration
- **resources/** - SSL certificates and keystores

## Usage

### Automatic (via Gradle)

The Docker services are automatically managed by Gradle tasks:

```bash
# Run all tests (automatically starts/stops Docker)
./gradlew :wso2.apim.catalog-ballerina-tests:test

# Or from root
./gradlew clean build
```

### Manual Docker Operations

#### Start Services

```bash
cd ballerina-tests/resources/mock-services
docker compose up -d --build
```

#### Check Status

```bash
docker ps --filter name=wso2-apim-mock-services
docker logs wso2-apim-mock-services
```

#### Health Check

```bash
curl http://localhost:8080/health
# Expected: "OK"
```

#### Stop Services

```bash
docker stop wso2-apim-mock-services
docker rm wso2-apim-mock-services

# Or using compose
docker compose down
```

#### Rebuild Image

```bash
docker compose up -d --build --force-recreate
```

### Gradle Tasks

#### Start Mock Services

```bash
./gradlew :wso2.apim.catalog-ballerina-tests:startMockServices
```

What it does:
- Checks if the container is already running
- Builds the Docker image if needed
- Starts the container using Docker Compose
- Waits 15 seconds for services to initialize
- Verifies health status

#### Stop Mock Services

```bash
./gradlew :wso2.apim.catalog-ballerina-tests:stopMockServices
```

What it does:
- Checks if the container is running
- Stops the container gracefully
- Waits 5 seconds for shutdown
- Removes the container

#### Run Tests with Docker

```bash
# Full test suite
./gradlew :wso2.apim.catalog-ballerina-tests:test

# The ballerinaTest task automatically:
# 1. Starts mock services (startMockServices)
# 2. Runs tests
# 3. Stops mock services (stopMockServices)
```

## Test Configuration

Each test project has a `Config.toml` file pointing to the appropriate Docker service:

```toml
[ballerinax.wso2.apim.catalog]
serviceUrl="http://localhost:8080"
tokenUrl="https://localhost:9444/oauth2/token"
username="abcd"
password="abcd"
clientId="aa"
clientSecret="aa"
```

## Troubleshooting

### Container won't start

```bash
# Check logs
docker logs wso2-apim-mock-services

# Check if ports are already in use
lsof -i :8080
lsof -i :9444

# Force recreate
docker compose down
docker compose up -d --build --force-recreate
```

### Tests fail with connection errors

```bash
# Verify services are running
docker ps

# Check health
curl http://localhost:8080/health

# Wait longer for startup
sleep 20
```

### Port conflicts

If ports 8080-8092 are in use, you'll need to:
1. Stop conflicting services
2. Or modify the compose.yml port mappings

### SSL/TLS errors

The mock services use self-signed certificates in `resources/ballerinaKeystore.p12`.
If you encounter SSL errors:
- Ensure the keystore file is copied correctly
- Check the keystore password is "ballerina"
- Verify the client truststore includes the certificate

## Development

### Modifying Services

1. Edit service files (service.bal, token_service.bal, etc.)
2. Rebuild the container:
   ```bash
   docker compose up -d --build
   ```

### Adding New Mock Endpoints

1. Add new listener in `service.bal` or `token_service.bal`
2. Add port to `compose.yml` ports section
3. Add port to `Dockerfile` EXPOSE line
4. Update test configs to use the new endpoint
5. Rebuild container

### Viewing Artifacts

Artifacts are saved to `/tmp/artifacts` inside the container:

```bash
docker exec wso2-apim-mock-services ls -la /tmp/artifacts
docker exec wso2-apim-mock-services cat /tmp/artifacts/artifacts_0.json
```

## Integration with CI/CD

The Docker setup is compatible with GitHub Actions and other CI/CD systems:

```yaml
- name: Run tests
  run: ./gradlew clean test
  # Docker services are automatically managed
```

Docker must be available in the CI environment.

## Notes

- Windows: Docker operations are automatically skipped on Windows
- Mac/Linux: Requires Docker Desktop or Docker Engine installed
- The container uses the Ballerina 2201.10.5 base image
- Health checks ensure services are ready before tests run
- All ports are exposed on localhost for test access
