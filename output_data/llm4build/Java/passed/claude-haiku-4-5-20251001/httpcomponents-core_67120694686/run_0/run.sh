#!/bin/bash

set -e

# Display Java version for debugging
java -version

# Display Maven wrapper version
./mvnw -v

# Build with Maven using the exact command from the YAML
./mvnw -V --file pom.xml --no-transfer-progress -DtrimStackTrace=false -Djunit.jupiter.execution.parallel.enabled=false -P-use-toolchains,docker

echo "Build completed successfully!"