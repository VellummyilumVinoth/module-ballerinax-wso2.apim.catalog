# 🚀 Quick Start - Testing Guide

## ⚠️ You Are Here

Docker integration is **100% implemented** but **Docker is not running**.

## 3 Steps to Test

### 1️⃣ Start Docker (1 minute)

```bash
# macOS - Open Docker Desktop
open -a Docker

# Wait for Docker icon in menu bar to stop animating
# Then verify:
docker ps
```

### 2️⃣ Quick Docker Test (2 minutes)

```bash
cd ballerina-tests/resources/mock-services
./test-docker.sh
```

**Expected:** All ✓ checkmarks, no ✗ errors

### 3️⃣ Full Test Suite (10-15 minutes)

```bash
cd /Users/vinoth/module-ballerinax-wso2.apim.catalog
./gradlew clean test
```

**Expected:** `BUILD SUCCESSFUL` + all tests passing

---

## Alternative: Using Makefile

```bash
cd ballerina-tests/resources/mock-services

# Quick test (build + start + test)
make quick

# Or step by step
make build      # Build Docker image
make start      # Start services
make test       # Run tests
make stop       # Stop services
```

---

## Troubleshooting

### Docker won't start
```bash
# Check if already running
docker ps

# Restart Docker Desktop
pkill -9 Docker && open -a Docker
```

### Port conflicts
```bash
# Find what's using ports
lsof -i :8080

# Kill the process
kill -9 <PID>
```

### Tests fail
```bash
# View Docker logs
docker logs wso2-apim-mock-services

# Run tests with debug
./gradlew clean test --info
```

---

## What's Been Implemented

✅ **Docker Compose** - Orchestrates 14 mock services
✅ **Dockerfile** - Builds Ballerina service image
✅ **Mock Services** - API Manager & OAuth2 endpoints
✅ **Gradle Tasks** - Auto start/stop Docker
✅ **Test Configs** - All 12 projects configured
✅ **Documentation** - Comprehensive guides
✅ **Test Scripts** - Automated testing

---

## Service Endpoints (when running)

| Port | Service | Purpose |
|------|---------|---------|
| 8080-8088 | API Manager | Standard endpoints |
| 8089 | API Manager | Connection failure test |
| 8090 | API Manager | Unauthorized test |
| 8092 | API Manager | Additional endpoint |
| 9444 | OAuth2 (HTTPS) | Token generation |
| 9441 | OAuth2 (HTTPS) | Token failure test |

---

## Files Reference

📖 **TEST_GUIDE.md** - Comprehensive testing guide
📖 **DOCKER_INTEGRATION.md** - Implementation details
📖 **TESTING_STATUS.md** - Current status
📖 **QUICK_START.md** - This file

📁 **ballerina-tests/resources/mock-services/** - Docker files
🔧 **test-docker.sh** - Docker health tests
🔧 **Makefile** - Convenient commands

---

## Success Indicators

### Docker Test Success ✓
```
✓ Docker daemon is running
✓ Container started
✓ Health check endpoint (8080) - OK
✓ All ports listening
✓ OAuth2 token endpoint - OK
```

### Gradle Test Success ✓
```
BUILD SUCCESSFUL in 3m 24s
Tests:
  testSingleService - 8 passed
  testSingleServiceWithConnectionRefuse - passed
  testSingleServiceWithTokenCallfailure - passed
  testSingleUnauthorizedService - passed

11 passing, 0 failing
```

---

## Need Help?

1. Read **TEST_GUIDE.md** for detailed troubleshooting
2. Check **TESTING_STATUS.md** for current status
3. Review **DOCKER_INTEGRATION.md** for architecture details

---

**Ready? Start Docker and run the tests! 🎉**
