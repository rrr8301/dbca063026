#!/bin/bash
set -e

# Verify Java and Maven are available
java -version
mvn -version

# Build project with Maven
mvn -T 4 --batch-mode -Djava.awt.headless=true verify -P enableTests,enableCheckStyle

echo "Build and tests completed successfully!"