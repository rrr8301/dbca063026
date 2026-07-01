#!/bin/bash

# Activate environment variables if needed (none in this case)

# Install project dependencies and build
./mvnw -V --file pom.xml --no-transfer-progress -DtrimStackTrace=false -Djunit.jupiter.execution.parallel.enabled=false -P-use-toolchains,docker

# Run tests
# Ensure all tests are executed, even if some fail
set +e
mvn test
set -e