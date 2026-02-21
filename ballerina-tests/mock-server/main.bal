// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
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
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/mime;
import ballerina/os;

type ServiceItem record {
    string id?;
    string name;
    string description?;
    string version;
    string serviceKey?;
    string serviceUrl;
    string definitionType;
    string securityType = "NONE";
    boolean mutualSSLEnabled = false;
    int usage?;
    string createdTime?;
    string lastUpdatedTime?;
    string md5?;
    string definitionUrl?;
};

type ServiceSchema record {
    ServiceItem serviceMetadata;
    string inlineContent?;
};

public function main() returns error? {
    string portStr = os:getEnv("PORT");
    string artifactIndexStr = os:getEnv("ARTIFACT_INDEX");
    string unauthorizedStr = os:getEnv("UNAUTHORIZED");
    string outputDir = os:getEnv("OUTPUT_DIR");

    int port = portStr.trim() == "" ? 8080 : check int:fromString(portStr.trim());
    int artifactIndex = artifactIndexStr.trim() == "" ? 0 : check int:fromString(artifactIndexStr.trim());
    boolean unauthorized = unauthorizedStr.trim() == "true";
    string artifactsDir = outputDir.trim() == "" ? "/artifacts" : outputDir.trim();

    string artifactFile = string `${artifactsDir}/artifacts_${artifactIndex}.json`;
    map<ServiceSchema> artifacts = {};

    http:Listener httpListener = check new (port);
    http:Service svc;

    if unauthorized {
        svc = service object {
            resource function get health() returns http:Ok {
                return {body: {status: "ok"}};
            }

            resource function get services(string? 'key = (), string? name = (), string? version = (),
                    string? definitionType = (), boolean shrink = false, string? sortBy = (),
                    string? sortOrder = (), int 'limit = 25, int offset = 0) returns json {
                return {"list": [], "pagination": {}};
            }

            resource function post services(http:Request req) returns http:Unauthorized|error {
                ServiceSchema schema = check traverseRequest(req);
                string serviceKey = schema.serviceMetadata.serviceKey ?: "";
                artifacts[serviceKey] = schema;
                check io:fileWriteJson(artifactFile, artifacts.toJson());
                return {body: {message: "Unauthorized"}};
            }
        };
    } else {
        svc = service object {
            resource function get health() returns http:Ok {
                return {body: {status: "ok"}};
            }

            resource function get services(string? 'key = (), string? name = (), string? version = (),
                    string? definitionType = (), boolean shrink = false, string? sortBy = (),
                    string? sortOrder = (), int 'limit = 25, int offset = 0) returns json {
                return {"list": [], "pagination": {}};
            }

            resource function post services(http:Request req) returns http:InternalServerError|error {
                ServiceSchema schema = check traverseRequest(req);
                string serviceKey = schema.serviceMetadata.serviceKey ?: "";
                artifacts[serviceKey] = schema;
                check io:fileWriteJson(artifactFile, artifacts.toJson());
                return {body: {message: "Return 500 Status code after completing the task"}};
            }
        };
    }

    check httpListener.attach(svc, "/");
    check httpListener.'start();
    runtime:registerListener(httpListener);
    log:printInfo(string `Mock catalog server started on port ${port}, artifactIndex=${artifactIndex}, unauthorized=${unauthorized}`);
}

function traverseRequest(http:Request req) returns ServiceSchema|error {
    mime:Entity[] bodyParts = check req.getBodyParts();
    ServiceItem serviceMetadata = check (check bodyParts[0].getJson()).cloneWithType();
    string inlineContent = check bodyParts[1].getText();
    return {serviceMetadata, inlineContent};
}
