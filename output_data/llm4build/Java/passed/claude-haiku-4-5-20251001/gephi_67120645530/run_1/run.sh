#!/bin/bash

set -e

# Clone the repository if not already present
if [ ! -f "pom.xml" ]; then
    echo "POM file not found. Cloning Gephi repository..."
    cd /workspace
    git clone https://github.com/gephi/gephi.git .
fi

# Display Java and Maven versions
echo "=== Java Version ==="
java -version

echo "=== Maven Version ==="
mvn -version

# Build project with Maven
echo "=== Building Gephi with Maven ==="
mvn -T 4 --batch-mode -Djava.awt.headless=true verify

echo "=== Build and Tests Completed Successfully ==="