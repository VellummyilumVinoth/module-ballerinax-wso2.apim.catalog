// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/file;
import ballerina/http;
import ballerina/io;
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/mime;
import ballerina/os;
import ballerina/test;

const decimal DOCKER_START_TIMEOUT = 15;
const int DOCKER_RETRY_COUNT = 10;
const decimal DOCKER_RETRY_DELAY = 2;

string sep = file:pathSeparator;
string currentDir = file:getCurrentDir();
string rootDir = check file:parentPath(currentDir);
string ballerinaTestDir = string `${rootDir}${sep}ballerina-tests${sep}tests`;
string bal = string `${rootDir}${sep}target${sep}ballerina-runtime${sep}bin${sep}bal`;
string artifactsHostPath = string `${ballerinaTestDir}${sep}generated_artifacts`;

// ---------------------------------------------------------------------------
// Docker container management — mirrors the module-ballerina-sql pattern
// ---------------------------------------------------------------------------

// Start a catalog API mock server container on the given port.
// Mounts the shared generated_artifacts directory so the test process can
// read the artifact JSON files written by the container.
function initializeMockServerContainer(string containerName, int port, int artifactIndex,
        boolean unauthorized = false) returns error? {
    if !check file:test(artifactsHostPath, file:EXISTS) {
        check file:createDir(artifactsHostPath);
    }

    os:Process result = check os:exec({
        value: "docker",
        arguments: [
            "run",
            "--rm",
            "-d",
            "--name", containerName,
            "-e", string `PORT=${port}`,
            "-e", string `ARTIFACT_INDEX=${artifactIndex}`,
            "-e", string `UNAUTHORIZED=${unauthorized}`,
            "-v", string `${artifactsHostPath}:/artifacts`,
            "-p", string `${port}:${port}`,
            "ballerinax/apim-catalog-mock-server:latest"
        ]
    });

    int exitCode = check result.waitForExit();
    if exitCode > 0 {
        return error(string `Docker container '${containerName}' failed to start. Exit code: ${exitCode}`);
    }
    io:println(string `Docker container '${containerName}' created, waiting for readiness...`);
    runtime:sleep(DOCKER_START_TIMEOUT);

    // Health-check the mock server via GET /health
    int counter = 0;
    while counter < DOCKER_RETRY_COUNT {
        http:Client|error httpClient = new (string `http://localhost:${port}`, {timeout: 3});
        if httpClient is http:Client {
            http:Response|error response = httpClient->get("/health");
            if response is http:Response && response.statusCode == 200 {
                break;
            }
        }
        counter += 1;
        runtime:sleep(DOCKER_RETRY_DELAY);
    }
    test:assertNotEquals(counter, DOCKER_RETRY_COUNT,
            string `Docker container '${containerName}' health check exceeded timeout!`);
    io:println(string `Docker container '${containerName}' is ready on port ${port}.`);
}

// Start the OAuth2 token server container (HTTPS).
// Mounts the test keystore into the container.
function initializeTokenServerContainer(string containerName, int port) returns error? {
    string keystoreAbsPath = check file:getAbsolutePath(
            string `${ballerinaTestDir}${sep}resources${sep}ballerinaKeystore.p12`);

    os:Process result = check os:exec({
        value: "docker",
        arguments: [
            "run",
            "--rm",
            "-d",
            "--name", containerName,
            "-e", string `PORT=${port}`,
            "-e", "KEYSTORE_PATH=/resources/ballerinaKeystore.p12",
            "-e", "KEYSTORE_PASSWORD=ballerina",
            "-v", string `${keystoreAbsPath}:/resources/ballerinaKeystore.p12:ro`,
            "-p", string `${port}:${port}`,
            "ballerinax/apim-catalog-token-server:latest"
        ]
    });

    int exitCode = check result.waitForExit();
    if exitCode > 0 {
        return error(string `Docker container '${containerName}' failed to start. Exit code: ${exitCode}`);
    }
    io:println(string `Docker container '${containerName}' created, waiting for readiness...`);
    runtime:sleep(DOCKER_START_TIMEOUT);

    // Health-check via HTTPS (skip certificate verification for the self-signed test cert)
    int counter = 0;
    while counter < DOCKER_RETRY_COUNT {
        http:Client|error httpClient = new (string `https://localhost:${port}`, {
            secureSocket: {enable: false},
            timeout: 3
        });
        if httpClient is http:Client {
            http:Response|error response = httpClient->post("/oauth2/token", {});
            if response is http:Response && response.statusCode == 200 {
                break;
            }
        }
        counter += 1;
        runtime:sleep(DOCKER_RETRY_DELAY);
    }
    test:assertNotEquals(counter, DOCKER_RETRY_COUNT,
            string `Docker container '${containerName}' health check exceeded timeout!`);
    io:println(string `Docker container '${containerName}' is ready on port ${port}.`);
}

// Stop and remove a Docker container.
function cleanDockerContainer(string containerName) returns error? {
    os:Process result = check os:exec({
        value: "docker",
        arguments: ["stop", containerName]
    });
    int exitCode = check result.waitForExit();
    test:assertExactEquals(exitCode, 0, string `Docker container '${containerName}' stop failed!`);
    io:println(string `Cleaned docker container '${containerName}'.`);
}

// ---------------------------------------------------------------------------
// Test helper utilities
// ---------------------------------------------------------------------------

function runOSCommand(string projName, string projPath, string configFilePath) returns error? {
    os:Process|os:Error process = os:exec({
        value: string `${bal}`,
        arguments: ["run", string `${projPath}`]
    },
        BAL_CONFIG_FILES = configFilePath
    );

    if process is error {
        log:printInfo(
            string `Error while exec run command in :- ${projName}, e = ${process.message()}`);
        return process;
    }

    int|os:Error exitStatus = process.waitForExit();

    if exitStatus is os:Error {
        log:printInfo(
            string `Error while waiting for exit in :- ${projName}, e = ${exitStatus.message()}`);
        return exitStatus;
    } else {
        string output = check string:fromBytes(check process.output(io:stderr));
        if exitStatus != 0 {
            return error(string `${output}`);
        }
    }
}

function getProjName(int i) returns string {
    return string `test_sample_${i}`;
}

function getProjPath(int i) returns string {
    return string `${rootDir}${sep}test-resources${sep}sample_project_${i}`;
}

function getConfigFilePath(int i) returns string {
    return string `${currentDir}${sep}tests${sep}configs${sep}sample_project_${i}${sep}Config.toml`;
}

function traverseMultiPartRequest(http:Request req) returns ServiceSchema|error {
    mime:Entity[] bodyParts = check req.getBodyParts();
    Service serviceMetadata = check (check bodyParts[0].getJson()).cloneWithType();
    string inlineContent = check bodyParts[1].getText();
    return {
        serviceMetadata,
        inlineContent
    };
}

function returnDummyResponse(string message = "Return 500 Status code after completing the task")
            returns http:InternalServerError {
    return {
        body: {
            message
        }
    };
}

function readAndValidateArtifacts(string file, int index, string basePathPrefix = "/sales") {
    string artifactPath = string `${ballerinaTestDir}${sep}generated_artifacts`;
    json|error artifactJson = io:fileReadJson(string `${artifactPath}${sep}${file}`);

    if artifactJson is error {
        test:assertFail(string `Error while reading the ${file}`);
    }

    map<ServiceSchema>|error artifacts = artifactJson.cloneWithType();
    if artifacts is error {
        test:assertFail(string `Error while cloning the artifacts in ${file}`);
    }

    validateArtifacts(artifacts, index, basePathPrefix);
}

function validateArtifacts(map<ServiceSchema> artifacts, int index, string basePathPrefix) {
    string assertPath = string `${ballerinaTestDir}${sep}asserts`;
    string assertFile = string `assert_${index}.json`;
    json|error assertJson = io:fileReadJson(string `${assertPath}${sep}${assertFile}`);

    if assertJson is error {
        test:assertFail(string `Error while reading the ${assertFile}`);
    }

    map<ServiceSchema>|error assertArtifacts = assertJson.cloneWithType();
    if assertArtifacts is error {
        test:assertFail(
            string `Error while cloning the assertArtifacts in ${assertFile}, error = ${assertArtifacts.message()}, detail = ${assertArtifacts.detail().toBalString()}`
        );
    }

    foreach [string, ServiceSchema] [serviceKey, schema] in artifacts.entries() {
        if !assertArtifacts.hasKey(serviceKey) {
            test:assertFail(string `Service key ${serviceKey} not found in assert file ${assertFile}`);
        }

        ServiceSchema assertSchema = assertArtifacts.get(serviceKey);
        if isNameStartWithSamePrefix(assertSchema.serviceMetadata.name,
                schema.serviceMetadata.name, basePathPrefix) {
            assertSchema.serviceMetadata.name = schema.serviceMetadata.name;
            test:assertEquals(assertSchema, schema);
        } else {
            test:assertFail(string `Service name ${schema.serviceMetadata.name} not start with ${basePathPrefix}`);
        }
    }
}

function isNameStartWithSamePrefix(string assertSchemaName, string schemaName, string basePathPrefix) returns boolean {
    return assertSchemaName.startsWith(basePathPrefix) && schemaName.startsWith(basePathPrefix);
}
