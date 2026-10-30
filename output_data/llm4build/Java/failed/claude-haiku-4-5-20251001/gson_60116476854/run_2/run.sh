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

# Navigate to the repository root
cd /workspace

# Verify pom.xml exists
if [ ! -f "pom.xml" ]; then
    echo "ERROR: pom.xml not found in /workspace"
    exit 1
fi

# Run Maven build with verification and javadoc jar generation
mvn verify javadoc:jar \
    --show-version \
    --batch-mode \
    --no-transfer-progress

echo ""
echo "=== Build completed successfully ==="