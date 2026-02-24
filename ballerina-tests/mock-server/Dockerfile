# Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.

# Stage 1: Build the Ballerina fat JAR
FROM ballerina/ballerina:2201.13.1 AS builder
WORKDIR /app
COPY --chown=ballerina:ballerina . .
RUN bal build

# Stage 2: Minimal runtime image
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=builder /app/target/bin/apim_catalog_mock_server.jar /app/mock-server.jar

ENV PORT=8080
ENV ARTIFACT_INDEX=0
ENV UNAUTHORIZED=false
ENV OUTPUT_DIR=/artifacts

EXPOSE ${PORT}

ENTRYPOINT ["java", "-jar", "/app/mock-server.jar"]
