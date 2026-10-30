#!/bin/bash

set -e

# Print commands for debugging
set -x

# Ensure we're in the workspace
cd /workspace

# Maven install (skip tests)
echo "=== Maven Install (skip tests) ==="
./mvnw -B -ntp -Dtoolchain.skip install -U -DskipTests=true -f pom.xml

# Maven verify (run tests with JDK 11)
echo "=== Maven Verify (run tests) ==="
./mvnw -B -ntp -P!standard-with-extra-repos -Dtoolchain.skip verify -U -Dmaven.javadoc.skip=true -Dsurefire.toolchain.version=11 -f pom.xml || MAVEN_FAILED=true

# Print Surefire reports if Maven failed
if [ "$MAVEN_FAILED" = true ]; then
    echo "=== Printing Surefire Reports ==="
    if [ -f util/print_surefire_reports.sh ]; then
        bash util/print_surefire_reports.sh
    fi
fi

# Setup Gradle and run integration tests
echo "=== Gradle Integration Tests ==="
if [ -f util/gradle_integration_tests.sh ]; then
    bash util/gradle_integration_tests.sh
fi

echo "=== All tests completed ==="