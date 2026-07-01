#!/bin/bash

set -e

# Clone the repository if not already present
if [ ! -f "pom.xml" ]; then
    echo "POM file not found. Cloning Gephi repository..."
    # Check if .git directory exists (already a git repo)
    if [ ! -d ".git" ]; then
        # Clone into a temporary directory and move contents
        cd /tmp
        git clone https://github.com/gephi/gephi.git gephi-temp
        cd gephi-temp
        # Move all contents to /workspace
        mv -f ./* /workspace/
        mv -f ./.git* /workspace/
        cd /workspace
        rm -rf /tmp/gephi-temp
    fi
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