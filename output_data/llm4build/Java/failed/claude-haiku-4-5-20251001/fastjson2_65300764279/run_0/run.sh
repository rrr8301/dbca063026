#!/bin/bash

set -e

# Clone or use existing repository (in this case, already copied)
cd /workspace

# Display Maven version
./mvnw -V

# Build with Maven using the exact command from the workflow
# This includes running tests as part of the package goal
./mvnw --no-transfer-progress -Dfastjson2.creator=reflect clean package

echo "Build and tests completed successfully!"