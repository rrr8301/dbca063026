#!/bin/bash

set -e

# Print environment info
echo "=== Environment Info ==="
java -version
echo "JAVA_HOME: $JAVA_HOME"
echo "PATH: $PATH"
echo ""

# Navigate to workspace
cd /workspace

# Maven Install (skip tests)
echo "=== Maven Install ==="
mvn -B -ntp -Dtoolchain.skip install -U -DskipTests=true -Drat.skip=true -Dlicense.skip=true -f pom.xml

# Maven Verify (run tests with JDK 11)
echo "=== Maven Verify (Tests) ==="
mvn -B -ntp -P!standard-with-extra-repos -Dtoolchain.skip verify -U -Dmaven.javadoc.skip=true -Dsurefire.toolchain.version=11 -Drat.skip=true -Dlicense.skip=true -f pom.xml

# Gradle Integration Tests
echo "=== Gradle Integration Tests ==="
bash util/gradle_integration_tests.sh

echo "=== All Tests Completed Successfully ==="