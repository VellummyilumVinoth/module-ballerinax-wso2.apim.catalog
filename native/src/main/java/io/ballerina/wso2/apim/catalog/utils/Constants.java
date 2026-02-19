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

package io.ballerina.wso2.apim.catalog.utils;

/**
 * Constants used in the service catalog.
 *
 * @since 0.1.0
 */
public final class Constants {
    public static final String SERVICE_ARTIFACT_TYPE_NAME = "ServiceArtifact";
    public static final String LISTENERS = "listeners";
    public static final String ATTACH_POINT = "attachPoint";
    public static final String SERVICE = "service";
    public static final String NAME = "name";
    public static final String DESCRIPTION = "description";
    public static final String VERSION = "version";
    public static final String SERVICE_KEY = "serviceKey";
    public static final String SERVICE_URL = "serviceUrl";
    public static final String DEFINITION_TYPE = "definitionType";
    public static final String SECURITY_TYPE = "securityType";
    public static final String MUTUAL_SSL_ENABLED = "mutualSSLEnabled";
    public static final String MD5 = "md5";
    public static final String DEFINITION_URL = "definitionUrl";
    public static final String SLASH = "/";
    public static final String SERVICE_CATALOG_PACKAGE_NAME = "wso2.apim.catalog";
    public static final String CONTROL_PLANE_PACKAGE_NAME = "wso2.controlplane";
    public static final String SERVICE_CATALOG_METADATA_ANNOTATION_IDENTIFIER = "ServiceCatalogConfig";
    public static final String COLON = ":";
    public static final String MODULE_NAME = "ballerinax";
    public static final String OPENAPI_DEFINITION = "openApiDefinition";
    public static final String DEFINITION_FILE_CONTENT = "definitionFileContent";
    public static final String COMPLETE_MODULE_NAME = MODULE_NAME + SLASH + SERVICE_CATALOG_PACKAGE_NAME;
    public static final String HTTP_MODULE_NAME = "ballerina/http";
    public static final String HTTP_ANNOTATION_NAME = "ServiceConfig";
    public static final String HOST = "host";
    public static final String LOCALHOST = "localhost";
    public static final String PORT = "port";
    public static final String OAS3 = "OAS3";
    public static final String BASIC = "BASIC";
    public static final String NONE = "NONE";
    public static final String OAUTH2 = "OAUTH2";
    public static final String AUTH = "auth";
    public static final String CONFIG = "config";
    public static final String SECURE_SOCKET = "secureSocket";
    public static final String MUTUAL_SSL = "mutualSsl";
    public static final String UTF8 = "UTF-8";
    public static final String MD5_ALGO_NAME = "MD5";
    public static final String JWT_AUTH = "jwtValidatorConfig";
    public static final String OAUTH2_AUTH = "oauth2IntrospectionConfig";
    public static final String DEFAULT_STRING = "";
    public static final String HTTP_PACKAGE_NAME = "http";
    public static final String BALLERINA = "ballerina";

    private Constants() {
    }
}
