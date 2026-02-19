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
import ballerina/mime;

const string ARTIFACT_DIR = "/tmp/artifacts";

function getSchemaAndReturnResponse(http:Request req, string artifactJsonFilename, ServiceSchema[] artifacts)
        returns Service|http:InternalServerError|error {
    ServiceSchema schema = check traverseMultiPartRequest(req);
    artifacts.push(schema);

    // Save artifacts to file - convert to json
    json artifactsJson = check artifacts.cloneWithType(json);
    check io:fileWriteJson(artifactJsonFilename, artifactsJson);

    log:printInfo(string `Artifact saved to ${artifactJsonFilename}`);

    return returnDummyResponse();
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

function returnDummyResponse(string message = "Service registered successfully")
        returns http:InternalServerError {
    // Return 500 to terminate the client process after successful registration
    return {
        body: {
            message
        }
    };
}
