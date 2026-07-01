#!/usr/bin/env bash

set -e

export ROOT_POM="pom.xml"

echo "=== Step 1: Install ==="
./mvnw -B -ntp install -U -DskipTests=true -f $ROOT_POM
echo "Install step completed"

echo ""
echo "=== Step 2: Test ==="
./mvnw -B -ntp -P!standard-with-extra-repos verify -U -Dmaven.javadoc.skip=true -Dsurefire.toolchain.version=11 -f $ROOT_POM
echo "Test step completed"

echo ""
echo "=== Step 3: Integration Test ==="
bash util/gradle_integration_tests.sh
echo "Integration test step completed"

echo ""
echo "FINAL_STATUS = SUCCESS"
