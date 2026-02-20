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

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.swagger.parser.OpenAPIParser;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.parser.core.models.ParseOptions;

import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.StringJoiner;

import static io.ballerina.wso2.apim.catalog.utils.Constants.AUTH;
import static io.ballerina.wso2.apim.catalog.utils.Constants.BASIC;
import static io.ballerina.wso2.apim.catalog.utils.Constants.COLON;
import static io.ballerina.wso2.apim.catalog.utils.Constants.COMPLETE_MODULE_NAME;
import static io.ballerina.wso2.apim.catalog.utils.Constants.HOST;
import static io.ballerina.wso2.apim.catalog.utils.Constants.HTTP_ANNOTATION_NAME;
import static io.ballerina.wso2.apim.catalog.utils.Constants.HTTP_PREFIX; 
import static io.ballerina.wso2.apim.catalog.utils.Constants.HTTP_MODULE_NAME;
import static io.ballerina.wso2.apim.catalog.utils.Constants.JWT_AUTH;
import static io.ballerina.wso2.apim.catalog.utils.Constants.LOCALHOST;
import static io.ballerina.wso2.apim.catalog.utils.Constants.MD5_ALGO_NAME;
import static io.ballerina.wso2.apim.catalog.utils.Constants.NONE;
import static io.ballerina.wso2.apim.catalog.utils.Constants.OAS3;
import static io.ballerina.wso2.apim.catalog.utils.Constants.OAUTH2;
import static io.ballerina.wso2.apim.catalog.utils.Constants.OAUTH2_AUTH;
import static io.ballerina.wso2.apim.catalog.utils.Constants.OPENAPI_DEFINITION;
import static io.ballerina.wso2.apim.catalog.utils.Constants.SERVICE_CATALOG_METADATA_ANNOTATION_IDENTIFIER;
import static io.ballerina.wso2.apim.catalog.utils.Constants.SLASH;
import static io.ballerina.wso2.apim.catalog.utils.Constants.UTF8;

/**
 * Utility functions used in the service catalog.
 *
 * @since 0.1.0
 */
public final class Utils {
    private Utils() {
    }

    public static String createMd5Hash(String string) {
        try {
            byte[] bytesOfMessage = string.getBytes(UTF8);
            MessageDigest md = MessageDigest.getInstance(MD5_ALGO_NAME);
            return new String(md.digest(bytesOfMessage), StandardCharsets.UTF_8);
        } catch (UnsupportedEncodingException | NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }

    public static String getSecurityType(BMap<BString, Object> httpAnnotation) {
        if (httpAnnotation.containsKey(StringUtils.fromString(AUTH))) {
            BArray authArray = httpAnnotation.getArrayValue(StringUtils.fromString(AUTH));
            for (Object authObject: authArray.getValues()) {
                BMap<BString, Object> auth = (BMap<BString, Object>) authObject;
                if (auth.containsKey(StringUtils.fromString(OAUTH2_AUTH))
                        || auth.containsKey(StringUtils.fromString(JWT_AUTH))) {
                    return OAUTH2;
                }
            }
            return BASIC;
        }
        return NONE;
    }

    public static String getDefinitionType() {
        return OAS3;
    }

    public static String getHostname(BMap<BString, Object> annotation) {
        if (annotation == null || !annotation.containsKey(StringUtils.fromString(HOST))) {
            return LOCALHOST;
        }
        return HTTP_PREFIX + StringUtils.getStringValue(annotation.get(StringUtils.fromString(HOST))); 
    }

    public static OpenAPI getOpenApiDefinition(BMap<BString, Object> annotation) {

        BArray openApiDef = (BArray) annotation.get(StringUtils.fromString(OPENAPI_DEFINITION));
        byte[] openApiDefByteStream = openApiDef.getByteArray();
        String string = new String(openApiDefByteStream, StandardCharsets.UTF_8);
        ParseOptions parseOptions = new ParseOptions();
        parseOptions.setResolve(true);
        parseOptions.setResolveFully(true);
        return new OpenAPIParser().readContents(string, null, parseOptions).getOpenAPI();
    }

    public static String generateBasePath(BArray attachPointsArray) {
        if (attachPointsArray == null) {
            return SLASH;
        }

        String[] attachPoints = attachPointsArray.getStringArray();
        if (attachPoints.length == 0) {
            return SLASH;
        }

        StringJoiner sj = new StringJoiner(SLASH, SLASH, "");
        for (int i = 0; i < attachPoints.length; i++) {
            sj.add(attachPoints[i]);
        }
        return sj.toString();
    }

    public static BMap<BString, Object> getModuleAnnotation(BMap<BString, Object> annotations) {
        return getAnnotation(COMPLETE_MODULE_NAME, SERVICE_CATALOG_METADATA_ANNOTATION_IDENTIFIER, annotations);
    }

    public static BMap<BString, Object> getHttpAnnotation(BMap<BString, Object> annotations) {
        return getAnnotation(HTTP_MODULE_NAME, HTTP_ANNOTATION_NAME, annotations);
    }

    public static BMap<BString, Object> getAnnotation(String moduleName, String annotationName,
                                                      BMap<BString, Object> annotations) {
        if (annotations != null) {
            for (BString key : annotations.getKeys()) {
                String[] annotNames = StringUtils.getStringValue(key).split(COLON);
                if (annotNames[0].equals(moduleName) &&
                        annotNames[annotNames.length - 1].equals(annotationName)) {
                    return (BMap<BString, Object>) annotations.get(key);
                }
            }
        }
        return null;
    }
}
