#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an environment variable or argument)
# For local testing, the repo should be mounted or copied
if [ ! -d ".git" ]; then
    echo "Repository not found. Assuming code is already in /workspace"
fi

# Display Java and Maven versions
echo "=== Java Version ==="
java -version

echo "=== Maven Version ==="
mvn -version

# Build project with Maven
echo "=== Building Gephi with Maven ==="
mvn -T 4 --batch-mode -Djava.awt.headless=true verify -P enableTests,enableCheckStyle

echo "=== Build and Tests Completed Successfully ==="