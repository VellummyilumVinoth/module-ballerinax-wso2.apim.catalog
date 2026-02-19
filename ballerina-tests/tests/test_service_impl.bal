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
import ballerina/io;
import ballerina/log;
import ballerinax/wso2.apim.catalog;

final string artifactPath = string `${ballerinaTestDir}${sep}generated_artifacts`;

service / on new http:Listener(8080) {
    catalog:ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${artifactPath}${sep}artifacts_0.json`;

    function init() returns error? {
        log:printInfo("Starting the test server on port 8080");
    }

    resource function get services(string 'key) returns catalog:ServiceList {
        return {list: []};
    }

    resource function post services(http:Request req) returns catalog:Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

service / on new http:Listener(8081) {
    catalog:ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${artifactPath}${sep}artifacts_1.json`;

    function init() returns error? {
        log:printInfo("Starting the test server on port 8081");
    }

    resource function get services(string 'key) returns catalog:ServiceList {
        return {list: []};
    }

    resource function post services(http:Request req) returns catalog:Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

service / on new http:Listener(8082) {
    catalog:ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${artifactPath}${sep}artifacts_2.json`;

    function init() returns error? {
        log:printInfo("Starting the test server on port 8082");
    }

    resource function get services(string 'key) returns catalog:ServiceList {
        return {list: []};
    }

    resource function post services(http:Request req) returns catalog:Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

service / on new http:Listener(8083) {
    catalog:ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${artifactPath}${sep}artifacts_3.json`;

    function init() returns error? {
        log:printInfo("Starting the test server on port 8083");
    }

    resource function get services(string 'key) returns catalog:ServiceList {
        return {list: []};
    }

    resource function post services(http:Request req) returns catalog:Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

service / on new http:Listener(8092) {
    catalog:ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${artifactPath}${sep}artifacts_4.json`;

    function init() returns error? {
        log:printInfo("Starting the test server on port 8092");
    }

    resource function get services(string 'key) returns catalog:ServiceList {
        return {list: []};
    }

    resource function post services(http:Request req) returns catalog:Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

service / on new http:Listener(8085) {
    catalog:ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${artifactPath}${sep}artifacts_5.json`;

    function init() returns error? {
        log:printInfo("Starting the test server on port 8085");
    }

    resource function get services(string 'key) returns catalog:ServiceList {
        return {list: []};
    }

    resource function post services(http:Request req) returns catalog:Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

service / on new http:Listener(8086) {
    catalog:ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${artifactPath}${sep}artifacts_6.json`;

    function init() returns error? {
        log:printInfo("Starting the test server on port 8086");
    }

    resource function get services(string 'key) returns catalog:ServiceList {
        return {list: []};
    }

    resource function post services(http:Request req) returns catalog:Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

service / on new http:Listener(8087) {
    catalog:ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${artifactPath}${sep}artifacts_7.json`;

    function init() returns error? {
        log:printInfo("Starting the test server on port 8087");
    }

    resource function get services(string 'key) returns catalog:ServiceList {
        return {list: []};
    }

    resource function post services(http:Request req) returns catalog:Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

service / on new http:Listener(8088) {
    catalog:ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${artifactPath}${sep}artifacts_8.json`;

    function init() returns error? {
        log:printInfo("Starting the test server on port 8088");
    }

    resource function get services(string 'key) returns catalog:ServiceList {
        return {list: []};
    }

    resource function post services(http:Request req) returns catalog:Service|http:InternalServerError|error {
        return getSchemaAndReturnResponse(req, self.artifactJsonFilename, self.artifacts);
    }
}

service / on new http:Listener(8091) {
    catalog:ServiceSchema[] artifacts = [];
    final string artifactJsonFilename = string `${artifactPath}${sep}artifacts_11.json`;

    function init() returns error? {
        log:printInfo("Starting the test server on port 8091");
    }

    resource function get services(string 'key) returns catalog:ServiceList {
        return {list: []};
    }

    resource function post services(http:Request req) returns catalog:Service|http:Unauthorized|error {
        catalog:ServiceSchema schema = check traverseMultiPartRequest(req);
        self.artifacts.push(schema);
        check io:fileWriteJson(self.artifactJsonFilename, self.artifacts.toJson());
        return {body: {message: "Unauthorized"}};
    }
}

function getSchemaAndReturnResponse(http:Request req,
        string artifactJsonFilename, catalog:ServiceSchema[] artifacts) returns http:InternalServerError|error {
    catalog:ServiceSchema schema = check traverseMultiPartRequest(req);
    artifacts.push(schema);
    check io:fileWriteJson(artifactJsonFilename, artifacts.toJson());
    return returnDummyResponse();
}
