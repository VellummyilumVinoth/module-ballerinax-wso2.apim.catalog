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
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/os;

const ACCESS_TOKEN = "2YotnFZFEjr1zCsicMWpAA";

public function main() returns error? {
    string portStr = os:getEnv("PORT");
    string keystorePath = os:getEnv("KEYSTORE_PATH");
    string keystorePassword = os:getEnv("KEYSTORE_PASSWORD");

    int port = portStr.trim() == "" ? 9444 : check int:fromString(portStr.trim());
    string ksPath = keystorePath.trim() == "" ? "/resources/ballerinaKeystore.p12" : keystorePath.trim();
    string ksPassword = keystorePassword.trim() == "" ? "ballerina" : keystorePassword.trim();

    http:Listener tokenListener = check new (port, {
        secureSocket: {
            key: {
                path: ksPath,
                password: ksPassword
            }
        }
    });

    http:Service svc = service object {
        resource function post token(http:Request req) returns http:Ok {
            return {
                body: {
                    "access_token": ACCESS_TOKEN,
                    "token_type": "example",
                    "expires_in": 3600,
                    "example_parameter": "example_value"
                }
            };
        }

        resource function post introspect(http:Request request) returns http:Ok {
            return {
                body: {"active": true, "exp": 3600, "scp": "write update"}
            };
        }
    };

    check tokenListener.attach(svc, "/oauth2");
    check tokenListener.'start();
    runtime:registerListener(tokenListener);
    log:printInfo(string `Token server started on port ${port}`);
}
