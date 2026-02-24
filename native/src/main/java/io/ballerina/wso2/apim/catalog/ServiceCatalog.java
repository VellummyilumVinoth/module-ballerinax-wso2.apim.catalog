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

package io.ballerina.wso2.apim.catalog;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.repository.Artifact;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.wso2.apim.catalog.utils.Constants;
import io.swagger.v3.core.util.Yaml;
import io.swagger.v3.oas.models.OpenAPI;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

import static io.ballerina.wso2.apim.catalog.utils.Constants.BALLERINA;
import static io.ballerina.wso2.apim.catalog.utils.Constants.CONTROL_PLANE_PACKAGE_NAME;
import static io.ballerina.wso2.apim.catalog.utils.Constants.HTTP_PACKAGE_NAME;
import static io.ballerina.wso2.apim.catalog.utils.Constants.MODULE_NAME;
import static io.ballerina.wso2.apim.catalog.utils.Utils.createMd5Hash;
import static io.ballerina.wso2.apim.catalog.utils.Utils.generateBasePath;
import static io.ballerina.wso2.apim.catalog.utils.Utils.getDefinitionType;
import static io.ballerina.wso2.apim.catalog.utils.Utils.getHostname;
import static io.ballerina.wso2.apim.catalog.utils.Utils.getHttpAnnotation;
import static io.ballerina.wso2.apim.catalog.utils.Utils.getModuleAnnotation;
import static io.ballerina.wso2.apim.catalog.utils.Utils.getOpenApiDefinition;
import static io.ballerina.wso2.apim.catalog.utils.Utils.getSecurityType;
import static io.ballerina.wso2.apim.catalog.utils.Constants.COLON;
import static io.ballerina.wso2.apim.catalog.utils.Constants.HTTP_PREFIX;
import static io.ballerina.wso2.apim.catalog.utils.Constants.CONFIG;
import static io.ballerina.wso2.apim.catalog.utils.Constants.DEFAULT_STRING;
import static io.ballerina.wso2.apim.catalog.utils.Constants.DEFINITION_FILE_CONTENT;
import static io.ballerina.wso2.apim.catalog.utils.Constants.DEFINITION_TYPE;
import static io.ballerina.wso2.apim.catalog.utils.Constants.DEFINITION_URL;
import static io.ballerina.wso2.apim.catalog.utils.Constants.DESCRIPTION;
import static io.ballerina.wso2.apim.catalog.utils.Constants.MD5;
import static io.ballerina.wso2.apim.catalog.utils.Constants.MUTUAL_SSL;
import static io.ballerina.wso2.apim.catalog.utils.Constants.MUTUAL_SSL_ENABLED;
import static io.ballerina.wso2.apim.catalog.utils.Constants.NAME;
import static io.ballerina.wso2.apim.catalog.utils.Constants.NONE;
import static io.ballerina.wso2.apim.catalog.utils.Constants.PORT;
import static io.ballerina.wso2.apim.catalog.utils.Constants.SECURE_SOCKET;
import static io.ballerina.wso2.apim.catalog.utils.Constants.SECURITY_TYPE;
import static io.ballerina.wso2.apim.catalog.utils.Constants.SERVICE_KEY;
import static io.ballerina.wso2.apim.catalog.utils.Constants.SERVICE_URL;
import static io.ballerina.wso2.apim.catalog.utils.Constants.VERSION;

/**
 * Provide functionality to retrieve artifacts details.
 *
 * @since 0.1.0
 */
public final class ServiceCatalog {
    private ServiceCatalog() {
    }

    public static BArray getArtifacts(Environment env) {
        Module currentModule = env.getCurrentModule();
        RecordType recordType = TypeCreator.createRecordType(Constants.SERVICE_ARTIFACT_TYPE_NAME,
                currentModule, 0, false, 0);
        ArrayType arrayType = TypeCreator.createArrayType(recordType);
        BArray arrayValue = ValueCreator.createArrayValue(arrayType);

        for (Artifact artifact : env.getRepository().getArtifacts()) {
            Object serviceObj = artifact.getDetail(Constants.SERVICE);
            Type originalType = ((BObject) serviceObj).getOriginalType();
            Module module = originalType.getPackage();
            if (module != null && module.equals(currentModule)) {
                continue;
            }
            if (module != null && MODULE_NAME.equals(module.getOrg())
                    && CONTROL_PLANE_PACKAGE_NAME.equals(module.getName())) {
                continue;
            }

            Object listenerDetails = artifact.getDetail(Constants.LISTENERS);
            if (!isHttpServiceNode(listenerDetails)) {
                continue;
            }

            BMap<BString, Object> artifactValues = ValueCreator.createRecordValue(recordType);
            Object attachPointDetails = artifact.getDetail(Constants.ATTACH_POINT);
            Object annotationDetails = getAnnotations(serviceObj);

            updateMetadata(env, artifactValues, listenerDetails, annotationDetails, attachPointDetails);
            arrayValue.append(artifactValues);
        }
        return arrayValue;
    }

    private static boolean isHttpServiceNode(Object listenerDetails) {
        Module pkg = (((ArrayList<BObject>) listenerDetails).get(0)).getOriginalType().
                getPackage();
        return pkg.getOrg().equals(BALLERINA) && pkg.getName().equals(HTTP_PACKAGE_NAME);
    }

    private static Object getAnnotations(Object serviceObj) {
        if (serviceObj == null) {
            return null;
        }
        BObject serviceBObj = (BObject) serviceObj;
        ObjectType impliedType = (ObjectType) TypeUtils.getImpliedType(serviceBObj.getOriginalType());
        return impliedType.getAnnotations();
    }

    private static void updateMetadata(Environment env, BMap<BString, Object> artifactValues, Object listenerDetails,
                                     Object annotationDetails, Object attachPointDetails) {
        BMap<BString, Object> httpAnnotation = getHttpAnnotation((BMap<BString, Object>) annotationDetails);
        HttpServiceConfig httpServiceConfig = updateHostAndPortAndBasePath(listenerDetails,
                attachPointDetails, httpAnnotation);
        updateServiceNameAndUrl(artifactValues, httpServiceConfig);
        updateAnnotationsArtifactValues(artifactValues, annotationDetails, httpAnnotation, env, httpServiceConfig);
        updateListenerConfigurations(artifactValues, listenerDetails);
        updateMd5(artifactValues);
    }

    private static void updateMd5(BMap<BString, Object> artifactValues) {
        String name = StringUtils.getStringValue(artifactValues.get(StringUtils.fromString(NAME)));
        String version = StringUtils.getStringValue(artifactValues.get(StringUtils.fromString(VERSION)));
        String definitionType = StringUtils.getStringValue(artifactValues.get(StringUtils.fromString(DEFINITION_TYPE)));
        String openapiDef = StringUtils.getStringValue(artifactValues.get(StringUtils
                .fromString(DEFINITION_FILE_CONTENT)));

        String string = name + version + definitionType + openapiDef;
        artifactValues.put(StringUtils.fromString(MD5), StringUtils.fromString(createMd5Hash(string)));
    }

    private static void updateServiceNameAndUrl(BMap<BString, Object> artifactValues,
                                                HttpServiceConfig httpServiceConfig) {
        updateServiceName(artifactValues, httpServiceConfig);
        updateServiceUrl(artifactValues, httpServiceConfig);
    }

    private static void updateListenerConfigurations(BMap<BString, Object> artifactValues, Object listenerDetails) {
        artifactValues.put(StringUtils.fromString(MUTUAL_SSL_ENABLED), getMutualSSLDetails(listenerDetails));
    }

    private static boolean getMutualSSLDetails(Object listenerDetails) {
        ArrayList<BObject> listenerArray = (ArrayList<BObject>) listenerDetails;
        if (!listenerArray.isEmpty()) {
            BObject listener = listenerArray.get(0);
            if (listener != null) {
                Object configObject = listener.getNativeData(CONFIG);
                if (configObject instanceof HashMap config
                        && config.containsKey(StringUtils.fromString(SECURE_SOCKET))) {
                    Object secureSocketObject = config.get(StringUtils.fromString(SECURE_SOCKET));
                    return secureSocketObject instanceof HashMap secureSocket
                            && secureSocket.containsKey(StringUtils.fromString(MUTUAL_SSL));
                }
            }
        }
        return false;
    }

    private static void updateServiceName(BMap<BString, Object> artifactValues, HttpServiceConfig httpServiceConfig) {
        String uniqueSuffix = UUID.randomUUID().toString().replace("-", "").
                substring(0, 10).toUpperCase(Locale.ROOT); // To temporarily resolve service name uniqueness conflicts
        artifactValues.put(StringUtils.fromString(NAME),
                StringUtils.fromString(httpServiceConfig.basePath + uniqueSuffix));
    }

    private static void updateServiceUrl(BMap<BString, Object> artifactValues, HttpServiceConfig httpServiceConfig) {
        String serviceUrl = httpServiceConfig.host + COLON + httpServiceConfig.port + httpServiceConfig.basePath;
        artifactValues.put(StringUtils.fromString(SERVICE_URL), StringUtils.fromString(serviceUrl));
        artifactValues.put(StringUtils.fromString(DEFINITION_URL), StringUtils.fromString(serviceUrl));
    }

    private static HttpServiceConfig updateHostAndPortAndBasePath(Object listenerDetails, Object attachPointDetails,
                                                                  BMap<BString, Object> httpAnnotation) {
        BArray attachPoints = (BArray) attachPointDetails;

        String basePath = generateBasePath(attachPoints);
        String port = getPortValue(listenerDetails);
        String host = getHostname(httpAnnotation);
        return new HttpServiceConfig(host, port, basePath);
    }

    private static String getPortValue(Object listenerDetails) {
        List<BObject> listenerArray = (ArrayList<BObject>) listenerDetails;
        return listenerArray.get(0).get(StringUtils.fromString(PORT)).toString();
    }

    private static void updateAnnotationsArtifactValues(BMap<BString, Object> artifactValues,
                                                        Object annotationDetail, BMap<BString, Object> httpAnnotation,
                                                        Environment env, HttpServiceConfig httpServiceConfig) {
        BMap<BString, Object> annotations = (BMap<BString, Object>) annotationDetail;
        BMap<BString, Object> moduleAnnotation = getModuleAnnotation(annotations);

        if (moduleAnnotation != null) {
            updateModuleAnnotationDetails(moduleAnnotation, artifactValues, httpServiceConfig);
        } else {
            artifactValues.put(StringUtils.fromString(VERSION), StringUtils
                    .fromString(env.getCurrentModule().getMajorVersion()));
            artifactValues.put(StringUtils.fromString(DEFINITION_FILE_CONTENT),
                    StringUtils.fromString(DEFAULT_STRING));
            artifactValues.put(StringUtils.fromString(DESCRIPTION),
                    StringUtils.fromString(DEFAULT_STRING));
            artifactValues.put(StringUtils.fromString(SERVICE_KEY),
                    StringUtils.fromString(httpServiceConfig.definitionUrl));
        }

        if (httpAnnotation != null) {
            artifactValues.put(StringUtils.fromString(SECURITY_TYPE),
                    StringUtils.fromString(getSecurityType(httpAnnotation)));
        } else {
            artifactValues.put(StringUtils.fromString(SECURITY_TYPE), StringUtils.fromString(NONE));
        }
        artifactValues.put(StringUtils.fromString(DEFINITION_TYPE), StringUtils.fromString(getDefinitionType()));
    }

    private static void updateModuleAnnotationDetails(BMap<BString, Object> moduleAnnotation,
                                                      BMap<BString, Object> artifactValues,
                                                      HttpServiceConfig httpServiceConfig) {
        OpenAPI openApiDef = getOpenApiDefinition(moduleAnnotation);
        String openApiDefVersion = openApiDef.getInfo().getVersion();
        String description = openApiDef.getInfo().getDescription();
        String title = openApiDef.getInfo().getTitle();

        artifactValues.put(StringUtils.fromString(DEFINITION_FILE_CONTENT),
                StringUtils.fromString(Yaml.pretty(openApiDef)));
        artifactValues.put(StringUtils.fromString(VERSION),
                StringUtils.fromString(openApiDefVersion != null ? openApiDefVersion : DEFAULT_STRING));
        artifactValues.put(StringUtils.fromString(DESCRIPTION),
                StringUtils.fromString(description != null ? description : DEFAULT_STRING));
        artifactValues.put(StringUtils.fromString(SERVICE_KEY),
                StringUtils.fromString(title != null ?
                        title + COLON + httpServiceConfig.definitionUrl
                        : DEFAULT_STRING + COLON + httpServiceConfig.definitionUrl));
    }

    static class HttpServiceConfig {
        String basePath;
        String host;
        String port;
        String definitionUrl;

        HttpServiceConfig(String host, String port, String basePath) {
            this.basePath = basePath;
            this.host = host;
            this.port = port;
            String hostWithoutProtocol = host.startsWith(HTTP_PREFIX) ? host.substring(HTTP_PREFIX.length()) : host;
            this.definitionUrl = hostWithoutProtocol + COLON + port + basePath;
        }
    }
}
