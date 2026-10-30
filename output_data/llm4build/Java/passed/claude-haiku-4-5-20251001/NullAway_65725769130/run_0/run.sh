#!/bin/bash

set -e

# Enable error handling: continue on errors but track them
FAILED=0

echo "=========================================="
echo "Starting NullAway Build and Test"
echo "=========================================="

# Step 1: Build and test
echo ""
echo "Step 1: Building and testing with Gradle..."
if ./gradlew build; then
    echo "✓ Build and test passed"
else
    echo "✗ Build and test failed"
    FAILED=1
fi

# Step 2: Run shellcheck
echo ""
echo "Step 2: Running shellcheck..."
if ./gradlew shellcheck; then
    echo "✓ Shellcheck passed"
else
    echo "✗ Shellcheck failed"
    FAILED=1
fi

# Step 3: Aggregate jacoco coverage
echo ""
echo "Step 3: Aggregating jacoco coverage..."
if ./gradlew codeCoverageReport; then
    echo "✓ Jacoco coverage report generated"
    COVERAGE_SUCCESS=true
else
    echo "✗ Jacoco coverage report failed (continuing...)"
    COVERAGE_SUCCESS=false
fi

# Step 4: Test publishToMavenLocal flow
echo ""
echo "Step 4: Testing publishToMavenLocal flow..."
export ORG_GRADLE_PROJECT_VERSION_NAME='0.0.0.1-LOCAL'
export ORG_GRADLE_PROJECT_RELEASE_SIGNING_ENABLED='false'
if ./gradlew publishToMavenLocal; then
    echo "✓ publishToMavenLocal passed"
else
    echo "✗ publishToMavenLocal failed"
    FAILED=1
fi

# Step 5: Check that Git tree is clean after build and test
echo ""
echo "Step 5: Checking that Git tree is clean..."
if ./.buildscript/check_git_clean.sh; then
    echo "✓ Git tree is clean"
else
    echo "✗ Git tree is not clean"
    FAILED=1
fi

echo ""
echo "=========================================="
if [ $FAILED -eq 0 ]; then
    echo "All tests completed successfully!"
    exit 0
else
    echo "Some tests failed. See output above."
    exit 1
fi