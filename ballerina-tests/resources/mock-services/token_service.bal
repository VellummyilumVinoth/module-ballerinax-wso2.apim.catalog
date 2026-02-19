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

const ACCESS_TOKEN_1 = "2YotnFZFEjr1zCsicMWpAA";
const keyStorePassword = "ballerina";
const keystorePath = "/app/resources/ballerinaKeystore.p12";

listener http:Listener sts = new (9444, {
    secureSocket: {
        key: {
            path: keystorePath,
            password: keyStorePassword
        }
    }
});

service /oauth2 on sts {
    function init() {
        log:printInfo("OAuth2 token server started on https://0.0.0.0:9444");
    }

    resource function post token(http:Request req) returns json {
        return {
            "access_token": ACCESS_TOKEN_1,
            "token_type": "example",
            "expires_in": 3600,
            "example_parameter": "example_value"
        };
    }

    resource function post introspect(http:Request request) returns json {
        return {"active": true, "exp": 3600, "scp": "write update"};
    }
}

// Token service on HTTPS port 9441 - Token call failure simulation
listener http:Listener failTokenSts = new (9441, {
    secureSocket: {
        key: {
            path: keystorePath,
            password: keyStorePassword
        }
    }
});

service /oauth2 on failTokenSts {
    function init() {
        log:printInfo("OAuth2 token failure service started on https://0.0.0.0:9441");
    }

    resource function post token(http:Request req) returns http:InternalServerError {
        return {
            body: {
                "error": "server_error",
                "error_description": "Failed to call the token endpoint"
            }
        };
    }
}
