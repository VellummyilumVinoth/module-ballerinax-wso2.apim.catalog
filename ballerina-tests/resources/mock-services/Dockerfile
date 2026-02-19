# Use Ballerina base image
FROM ballerina/ballerina:2201.13.1

WORKDIR /app

# Copy the mock service files
COPY service.bal /app/
COPY token_service.bal /app/
COPY types.bal /app/
COPY utils.bal /app/
COPY Ballerina.toml /app/
COPY resources/ /app/resources/

# Create artifacts directory
RUN mkdir -p /tmp/artifacts

# Build the application during Docker build to download dependencies
# This creates an executable JAR with all dependencies bundled
RUN bal build

# Expose all required ports
EXPOSE 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 8090 8091 8092 9444 9441

# Run the pre-built executable JAR
CMD ["java", "-jar", "./target/bin/apim_mock_services.jar"]
