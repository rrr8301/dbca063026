#!/bin/bash

set -e

# Display Java version for debugging
java -version

# Display Maven version
mvn -v

# Build with Maven using the exact command from the YAML
mvn -V --file pom.xml --no-transfer-progress -DtrimStackTrace=false -Djunit.jupiter.execution.parallel.enabled=false -P-use-toolchains,docker -Drat.skip=true -Dlicense.skip=true

echo "Build completed successfully!"