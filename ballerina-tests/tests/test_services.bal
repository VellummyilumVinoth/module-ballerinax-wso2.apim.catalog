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

import ballerina/test;

// ---------------------------------------------------------------------------
// Token server — started once before all groups, stopped after all groups
// ---------------------------------------------------------------------------

@test:BeforeSuite
function initTokenServerContainer() returns error? {
    check initializeTokenServerContainer("apim-catalog-token", 9444);
}

@test:AfterSuite {}
function cleanTokenServerContainer() returns error? {
    check cleanDockerContainer("apim-catalog-token");
}

// ---------------------------------------------------------------------------
// sample0 — port 8080, artifact index 0
// ---------------------------------------------------------------------------

@test:BeforeGroups {value: ["sample0"]}
function initSample0Container() returns error? {
    check initializeMockServerContainer("apim-catalog-mock-0", 8080, 0);
}

@test:AfterGroups {value: ["sample0"]}
function cleanSample0Container() returns error? {
    check cleanDockerContainer("apim-catalog-mock-0");
}

@test:Config {groups: ["sample0"]}
function testSample0() returns error? {
    int index = 0;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    readAndValidateArtifacts(string `artifacts_${index}.json`, index);
}

// ---------------------------------------------------------------------------
// sample1 — port 8081, artifact index 1
// ---------------------------------------------------------------------------

@test:BeforeGroups {value: ["sample1"]}
function initSample1Container() returns error? {
    check initializeMockServerContainer("apim-catalog-mock-1", 8081, 1);
}

@test:AfterGroups {value: ["sample1"]}
function cleanSample1Container() returns error? {
    check cleanDockerContainer("apim-catalog-mock-1");
}

@test:Config {groups: ["sample1"]}
function testSample1() returns error? {
    int index = 1;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    readAndValidateArtifacts(string `artifacts_${index}.json`, index);
}

// ---------------------------------------------------------------------------
// sample2 — port 8082, artifact index 2
// ---------------------------------------------------------------------------

@test:BeforeGroups {value: ["sample2"]}
function initSample2Container() returns error? {
    check initializeMockServerContainer("apim-catalog-mock-2", 8082, 2);
}

@test:AfterGroups {value: ["sample2"]}
function cleanSample2Container() returns error? {
    check cleanDockerContainer("apim-catalog-mock-2");
}

@test:Config {groups: ["sample2"]}
function testSample2() returns error? {
    int index = 2;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    readAndValidateArtifacts(string `artifacts_${index}.json`, index);
}

// ---------------------------------------------------------------------------
// sample3 — port 8083, artifact index 3
// ---------------------------------------------------------------------------

@test:BeforeGroups {value: ["sample3"]}
function initSample3Container() returns error? {
    check initializeMockServerContainer("apim-catalog-mock-3", 8083, 3);
}

@test:AfterGroups {value: ["sample3"]}
function cleanSample3Container() returns error? {
    check cleanDockerContainer("apim-catalog-mock-3");
}

@test:Config {groups: ["sample3"]}
function testSample3() returns error? {
    int index = 3;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    readAndValidateArtifacts(string `artifacts_${index}.json`, index);
}

// ---------------------------------------------------------------------------
// sample4 — port 8092, artifact index 4
// ---------------------------------------------------------------------------

@test:BeforeGroups {value: ["sample4"]}
function initSample4Container() returns error? {
    check initializeMockServerContainer("apim-catalog-mock-4", 8092, 4);
}

@test:AfterGroups {value: ["sample4"]}
function cleanSample4Container() returns error? {
    check cleanDockerContainer("apim-catalog-mock-4");
}

@test:Config {groups: ["sample4"]}
function testSample4() returns error? {
    int index = 4;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    readAndValidateArtifacts(string `artifacts_${index}.json`, index);
}

// ---------------------------------------------------------------------------
// sample5 — port 8085, artifact index 5
// ---------------------------------------------------------------------------

@test:BeforeGroups {value: ["sample5"]}
function initSample5Container() returns error? {
    check initializeMockServerContainer("apim-catalog-mock-5", 8085, 5);
}

@test:AfterGroups {value: ["sample5"]}
function cleanSample5Container() returns error? {
    check cleanDockerContainer("apim-catalog-mock-5");
}

@test:Config {groups: ["sample5"]}
function testSample5() returns error? {
    int index = 5;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    readAndValidateArtifacts(string `artifacts_${index}.json`, index);
}

// ---------------------------------------------------------------------------
// sample6 — port 8086, artifact index 6
// ---------------------------------------------------------------------------

@test:BeforeGroups {value: ["sample6"]}
function initSample6Container() returns error? {
    check initializeMockServerContainer("apim-catalog-mock-6", 8086, 6);
}

@test:AfterGroups {value: ["sample6"]}
function cleanSample6Container() returns error? {
    check cleanDockerContainer("apim-catalog-mock-6");
}

@test:Config {groups: ["sample6"]}
function testSample6() returns error? {
    int index = 6;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    readAndValidateArtifacts(string `artifacts_${index}.json`, index);
}

// ---------------------------------------------------------------------------
// sample7 — port 8087, artifact index 7 (basepath "/")
// ---------------------------------------------------------------------------

@test:BeforeGroups {value: ["sample7"]}
function initSample7Container() returns error? {
    check initializeMockServerContainer("apim-catalog-mock-7", 8087, 7);
}

@test:AfterGroups {value: ["sample7"]}
function cleanSample7Container() returns error? {
    check cleanDockerContainer("apim-catalog-mock-7");
}

@test:Config {groups: ["sample7"]}
function testSingleServiceWithBasepathAsSlash() returns error? {
    int index = 7;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    readAndValidateArtifacts(string `artifacts_${index}.json`, index, "/");
}

// ---------------------------------------------------------------------------
// sample8 — port 8088, artifact index 8
// ---------------------------------------------------------------------------

@test:BeforeGroups {value: ["sample8"]}
function initSample8Container() returns error? {
    check initializeMockServerContainer("apim-catalog-mock-8", 8088, 8);
}

@test:AfterGroups {value: ["sample8"]}
function cleanSample8Container() returns error? {
    check cleanDockerContainer("apim-catalog-mock-8");
}

@test:Config {groups: ["sample8"]}
function testSample8() returns error? {
    int index = 8;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    readAndValidateArtifacts(string `artifacts_${index}.json`, index);
}

// ---------------------------------------------------------------------------
// sample9 — port 1111 (no container — tests connection-refused handling)
// ---------------------------------------------------------------------------

@test:Config {groups: ["sample9"]}
function testSingleServiceWithConnectionRefuse() returns error? {
    int index = 9;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    test:assertTrue((<error>result).message().includes("Something wrong with the connection"));
}

// ---------------------------------------------------------------------------
// sample10 — port 8080 catalog, port 9441 token (wrong token URL — no container)
// Tests that a bad token endpoint causes a clear error before the catalog is called.
// ---------------------------------------------------------------------------

@test:Config {groups: ["sample10"]}
function testSingleServiceWithTokenCallFailure() returns error? {
    int index = 10;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    test:assertTrue((<error>result).message().includes("Failed to call the token endpoint"));
}

// ---------------------------------------------------------------------------
// sample11 — port 8091, artifact index 11 (Unauthorized response)
// ---------------------------------------------------------------------------

@test:BeforeGroups {value: ["sample11"]}
function initSample11Container() returns error? {
    check initializeMockServerContainer("apim-catalog-mock-11", 8091, 11, true);
}

@test:AfterGroups {value: ["sample11"]}
function cleanSample11Container() returns error? {
    check cleanDockerContainer("apim-catalog-mock-11");
}

@test:Config {groups: ["sample11"]}
function testSingleUnauthorizedService() returns error? {
    int index = 11;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    test:assertTrue((<error>result).message().includes("Unauthorized"));
}

// ---------------------------------------------------------------------------
// sample12 — port 8089, artifact index 12
// ---------------------------------------------------------------------------

@test:BeforeGroups {value: ["sample12"]}
function initSample12Container() returns error? {
    check initializeMockServerContainer("apim-catalog-mock-12", 8089, 12);
}

@test:AfterGroups {value: ["sample12"]}
function cleanSample12Container() returns error? {
    check cleanDockerContainer("apim-catalog-mock-12");
}

@test:Config {groups: ["sample12"]}
function testSample12() returns error? {
    int index = 12;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    readAndValidateArtifacts(string `artifacts_${index}.json`, index, "/healthcare");
}
