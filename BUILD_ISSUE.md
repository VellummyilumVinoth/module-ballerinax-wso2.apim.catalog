# Build Issue - Module Resolution Failure

## Problem Summary

The project fails to build with compilation errors in the main Ballerina module (`ballerinax/wso2.apim.catalog`).

## Error

```
ERROR [client.bal:(20:1,20:23)] cannot resolve module 'ballerina/http'
ERROR [service.bal:(17:1,17:23)] cannot resolve module 'ballerina/http'
ERROR [service.bal:(19:1,19:25)] cannot resolve module 'ballerina/oauth2'
```

## Root Cause

The Ballerina runtime at `target/ballerina-runtime/` does not have the standard library modules installed:

```bash
$ ls target/ballerina-runtime/lib/
test.zip  tools/
```

**Missing:** The `ballerina/http`, `ballerina/oauth2`, and other standard library modules are not present.

## Impact

- ❌ Main module cannot compile
- ❌ Tests cannot run
- ✅ Docker integration is fully implemented (not the cause)
- ✅ Gradle tasks are correct (not the cause)

## This Is NOT Caused By Docker Integration

The Docker integration implemented is completely separate from this build issue:
- Docker files are in `ballerina-tests/resources/mock-services/`
- Gradle Docker tasks work correctly
- The issue exists even without Docker changes

## Diagnosis

### Version Mismatch

The project has inconsistent Ballerina versions:

| File | Version |
|------|---------|
| `ballerina/Ballerina.toml` (was) | 2201.12.0 |
| `ballerina/Dependencies.toml` | 2201.13.1 |
| **Updated to** | 2201.13.1 |

Even after fixing the version mismatch, the module resolution fails.

### Missing Standard Libraries

The `copyStdlibs` Gradle task should populate standard libraries but they're missing:

```gradle
task copyStdlibs(type: Copy) {
    from configurations.ballerinaStdLibs
    into "$project.rootDir/target/ballerina-runtime/bir-cache/"
}
```

The standard libraries should be at:
- `target/ballerina-runtime/repo/bala/ballerina/http/...`
- `target/ballerina-runtime/repo/bala/ballerina/oauth2/...`

But they don't exist.

## Potential Solutions

### Solution 1: Use System Ballerina

If Ballerina is installed system-wide:

```bash
# Check system Ballerina
which bal
bal version

# Build using system Ballerina
cd ballerina
bal build
```

### Solution 2: Fix Gradle Setup

The issue is likely in `build.gradle` configuration. Check:

1. **Is `ballerinaStdLibs` configuration defined?**
   ```gradle
   configurations {
       ballerinaStdLibs
   }
   ```

2. **Are dependencies declared?**
   ```gradle
   dependencies {
       ballerinaStdLibs "org.ballerinalang:ballerina-stdlib:${ballerinaLangVersion}"
   }
   ```

3. **Does `copyStdlibs` run before `test`?**
   ```gradle
   task test {
       dependsOn copyStdlibs
   }
   ```

### Solution 3: Use Ballerina Central

Remove `--offline` flag and let Ballerina download dependencies from Central:

```bash
cd ballerina
bal build  # Without --offline
```

Then run tests:
```bash
cd ../ballerina-tests
bal test
```

### Solution 4: Check Gradle Properties

Verify `gradle.properties` has correct repositories:

```properties
ballerinaLangVersion=2201.13.1
ballerinaStdLibVersion=2201.13.1
```

## Recommended Actions

1. **Check if this worked before** - Is this a new issue or has the build always failed?

2. **Try building on a clean system** - Does it work on CI or another developer's machine?

3. **Check git history** - When did this break?
   ```bash
   git log --all --oneline -- ballerina/Ballerina.toml
   ```

4. **Compare with working branch** - Is there a working branch/tag to compare against?

5. **Check Ballerina documentation** - Has the build process changed in 2201.13.1?

## Testing Docker Integration (Workaround)

Even though the main build fails, we can still test the Docker setup:

### Option 1: Manual Docker Test

```bash
cd ballerina-tests/resources/mock-services

# Start Docker services
docker compose up -d --build

# Test manually
curl http://localhost:8080/health
curl -k https://localhost:9444/oauth2/token -X POST

# View logs
docker logs wso2-apim-mock-services

# Stop
docker compose down
```

### Option 2: Test Script

```bash
cd ballerina-tests/resources/mock-services
./test-docker.sh
```

This will verify:
- ✅ Docker image builds
- ✅ All 14 services start
- ✅ All ports are listening
- ✅ OAuth2 endpoints work
- ✅ Health checks pass

## Summary

| Component | Status |
|-----------|--------|
| Docker Integration | ✅ Complete |
| Gradle Docker Tasks | ✅ Working |
| Mock Services | ✅ Implemented |
| Documentation | ✅ Complete |
| **Main Module Build** | ❌ **Failing** |
| **Module Resolution** | ❌ **Broken** |

**The Docker integration is ready to use once the main module build issue is resolved.**

## Next Steps

1. Investigate why `ballerina/http` cannot be resolved
2. Check if standard libraries are in the Ballerina distribution
3. Verify Gradle configuration for stdlib dependencies
4. Consider using system-installed Ballerina as workaround
5. Check with team if this is a known issue

---

**Note:** This is a blocking issue for any development on this project, not just Docker testing. The main module needs to compile before any tests can run.
