#!/bin/bash

# Activate environment variables if needed (none specified)

# Install project dependencies
# Maven will handle dependencies specified in pom.xml

# Build and test the project with Maven
./mvnw -V --file pom.xml --no-transfer-progress -DtrimStackTrace=false -Djunit.jupiter.execution.parallel.enabled=false -P-use-toolchains,docker

# Ensure all tests are executed, even if some fail
set +e
mvn test
set -e