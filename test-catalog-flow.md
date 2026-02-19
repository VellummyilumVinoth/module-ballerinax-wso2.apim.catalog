# WSO2 APIM Catalog Flow Analysis

## How It Works

### 1. Compiler Plugin Phase (Build Time)
- When `remoteManagement=true` in Ballerina.toml
- Compiler plugin generates OpenAPI specs for services
- Specs are stored and retrieved via `getArtifacts()` native method

### 2. Runtime Publishing Phase (Run Time)
- Sample project imports: `import ballerinax/wso2.apim.catalog as _;`
- This loads the catalog module's `service.bal`
- The module creates a Listener on port 5050:
  ```ballerina
  listener Listener 'listener = new Listener(port);
  ```
- When the listener starts, it calls:
  ```ballerina
  ServiceArtifact[] artifacts = getArtifacts();
  check publishArtifacts(artifacts);
  ```
- `publishArtifacts()` POSTs each artifact to the catalog endpoint

### 3. Publishing Flow
```
Sample Project Run
  ↓
Catalog Module Listener Starts (port 5050)
  ↓
Get Artifacts (from compiler plugin)
  ↓
Authenticate with Token Service (OAuth2)
  ↓
POST to Service Catalog Endpoint (/services)
  ↓
Receive Response (Success or Error)
```

## Why Tests Are Failing

1. **Token Service Not Available**
   - Sample projects try to connect to token service at startup
   - Token service (port 9444) only runs during `bal test`
   - When we manually run sample projects, token service isn't available

2. **Artifacts Not Generated**
   - If token auth fails, publishing fails
   - No artifacts are saved to generated_artifacts/
   - Tests can't validate results

## Solution

The tests need to:
1. Start mock services (ports 8080-8092, 9444) BEFORE running sample projects
2. Wait for services to be ready
3. Run sample projects which will publish to mock services
4. Mock services save artifacts to generated_artifacts/
5. Tests validate artifacts against assert files

## Current Test Flow

```
bal test (in ballerina-tests/)
  ↓
Start Mock Services (test_service_impl.bal, test_token_service.bal)
  ├─ API Manager mocks: 8080-8092
  └─ OAuth2 token mock: 9444
  ↓
Run Test Functions
  ↓
testSingleService(index)
  ↓
runOSCommand() - Executes: bal run test-resources/sample_project_{index}
  ↓
Sample Project Starts
  ├─ Catalog Listener starts (port 5050)
  ├─ Calls getArtifacts()
  ├─ Authenticates with 9444 ← FAILS HERE
  └─ Should POST to 8080 (but never reaches this)
  ↓
Test tries to read artifacts_{index}.json
  ↓
FAIL: File doesn't exist
```

## What's Wrong

The catalog module is trying to connect to **real** token/service URLs, not the mock URLs from Config.toml!

Looking at service.bal:
```ballerina
configurable string serviceUrl = "https://apis.wso2.com/api/service-catalog/v1";
configurable string tokenUrl = "https://localhost:9443/oauth2/token";
```

These default values are hardcoded. The Config.toml values aren't being used!

## The Real Issue

The Config.toml file has:
```toml
[ballerinax.wso2.apim.catalog]
serviceUrl="http://localhost:8080"
tokenUrl="https://localhost:9444/oauth2/token"
```

But the catalog module's service.bal has different defaults. The config values need to match the module's namespace.

## Fix Required

The Config.toml is correctly formatted with `[ballerinax.wso2.apim.catalog]`.
The sample project should be picking up these configs when it runs.

Let me verify if the config is being passed correctly...
