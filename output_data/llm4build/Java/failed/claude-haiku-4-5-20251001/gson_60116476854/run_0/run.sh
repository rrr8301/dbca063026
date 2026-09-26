#!/bin/bash

set -e

# Print Java and Maven versions for debugging
echo "=== Java Version ==="
java -version

echo ""
echo "=== Maven Version ==="
mvn -version

echo ""
echo "=== Building Gson with Maven ==="

# Navigate to the repository root (assuming it's already cloned or mounted)
cd /workspace

# Run Maven build with verification and javadoc jar generation
# Using the MAVEN_ARGS from the workflow
mvn verify javadoc:jar \
    --show-version \
    --batch-mode \
    --no-transfer-progress

echo ""
echo "=== Build completed successfully ==="