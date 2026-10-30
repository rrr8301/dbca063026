#!/bin/bash
set -e

# Activate Java environment
export PATH="/root/.sdkman/candidates/java/current/bin:${PATH}"
export JAVA_HOME="/root/.sdkman/candidates/java/current"
export PATH="/opt/maven/bin:${PATH}"

# Verify Java and Maven are available
java -version
mvn -version

# Build project with Maven
# Using exact command from YAML with additional flags to skip RAT/license checks
mvn -T 4 --batch-mode -Djava.awt.headless=true verify -P enableTests,enableCheckStyle -Drat.skip=true -Dlicense.skip=true

echo "Build and tests completed successfully!"