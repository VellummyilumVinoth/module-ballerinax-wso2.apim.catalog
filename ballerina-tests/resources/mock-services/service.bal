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

import ballerina/http;
import ballerina/log;

const string ARTIFACT_PATH = "/tmp/artifacts";

// Service on port 8080
service / on new http:Listener(8080) {
    ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${ARTIFACT_PATH}/artifacts_0.json`;

    function init() returns error? {
        log:printInfo("Mock APIM service started on port 8080");
    }

    resource function post services(http:Request req) returns Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }

    resource function get health() returns string {
        return "OK";
    }
}

// Service on port 8081
service / on new http:Listener(8081) {
    ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${ARTIFACT_PATH}/artifacts_1.json`;

    function init() returns error? {
        log:printInfo("Mock APIM service started on port 8081");
    }

    resource function post services(http:Request req) returns Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

// Service on port 8082
service / on new http:Listener(8082) {
    ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${ARTIFACT_PATH}/artifacts_2.json`;

    function init() returns error? {
        log:printInfo("Mock APIM service started on port 8082");
    }

    resource function post services(http:Request req) returns Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

// Service on port 8083
service / on new http:Listener(8083) {
    ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${ARTIFACT_PATH}/artifacts_3.json`;

    function init() returns error? {
        log:printInfo("Mock APIM service started on port 8083");
    }

    resource function post services(http:Request req) returns Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

// Service on port 8084
service / on new http:Listener(8084) {
    ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${ARTIFACT_PATH}/artifacts_8.json`;

    function init() returns error? {
        log:printInfo("Mock APIM service started on port 8084");
    }

    resource function post services(http:Request req) returns Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

// Service on port 8085
service / on new http:Listener(8085) {
    ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${ARTIFACT_PATH}/artifacts_5.json`;

    function init() returns error? {
        log:printInfo("Mock APIM service started on port 8085");
    }

    resource function post services(http:Request req) returns Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

// Service on port 8086
service / on new http:Listener(8086) {
    ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${ARTIFACT_PATH}/artifacts_6.json`;

    function init() returns error? {
        log:printInfo("Mock APIM service started on port 8086");
    }

    resource function post services(http:Request req) returns Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

// Service on port 8087
service / on new http:Listener(8087) {
    ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${ARTIFACT_PATH}/artifacts_7.json`;

    function init() returns error? {
        log:printInfo("Mock APIM service started on port 8087");
    }

    resource function post services(http:Request req) returns Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

// Service on port 8092
service / on new http:Listener(8092) {
    ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${ARTIFACT_PATH}/artifacts_4.json`;

    function init() returns error? {
        log:printInfo("Mock APIM service started on port 8092");
    }

    resource function post services(http:Request req) returns Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

// Service on port 8088
service / on new http:Listener(8088) {
    ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${ARTIFACT_PATH}/artifacts_8.json`;

    function init() returns error? {
        log:printInfo("Mock APIM service started on port 8088");
    }

    resource function post services(http:Request req) returns Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

// Service on port 8089 - Connection refused simulation (doesn't respond)
service / on new http:Listener(8089) {
    function init() returns error? {
        log:printInfo("Mock APIM service started on port 8089 (connection refuse test)");
    }

    resource function post services(http:Request req) returns http:ServiceUnavailable {
        return {
            body: {
                message: "Something wrong with the connection"
            }
        };
    }
}

// Service on port 8090 - Unauthorized simulation
service / on new http:Listener(8090) {
    function init() returns error? {
        log:printInfo("Mock APIM service started on port 8090 (unauthorized test)");
    }

    resource function post services(http:Request req) returns http:Unauthorized {
        return {
            body: {
                message: "Unauthorized"
            }
        };
    }
}
