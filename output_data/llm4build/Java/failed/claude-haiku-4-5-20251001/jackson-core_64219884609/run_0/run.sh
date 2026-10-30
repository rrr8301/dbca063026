#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

echo "=========================================="
echo "Jackson Core - Build and Test"
echo "=========================================="

# Verify Java installation
echo "Java version:"
java -version

echo ""
echo "=========================================="
echo "Step 1: Build and Test"
echo "=========================================="
if ./mvnw -B -ff -ntp verify; then
    echo "✓ Build and test passed"
else
    echo "✗ Build and test failed"
    TEST_FAILED=1
fi

echo ""
echo "=========================================="
echo "Step 2: Extract project Maven version"
echo "=========================================="
PROJECT_VERSION=$(./mvnw org.apache.maven.plugins:maven-help-plugin:3.5.1:evaluate -DforceStdout -Dexpression=project.version -q)
echo "Project version: $PROJECT_VERSION"

echo ""
echo "=========================================="
echo "Step 3: Verify Android SDK Compatibility"
echo "=========================================="
if ./mvnw -B -q -ff -ntp -DskipTests animal-sniffer:check; then
    echo "✓ Android SDK compatibility check passed"
else
    echo "✗ Android SDK compatibility check failed"
    TEST_FAILED=1
fi

echo ""
echo "=========================================="
echo "Step 4: Generate code coverage"
echo "=========================================="
if ./mvnw -B -q -ff -ntp test jacoco:report; then
    echo "✓ Code coverage generated"
else
    echo "✗ Code coverage generation failed"
    TEST_FAILED=1
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
if [ $TEST_FAILED -eq 0 ]; then
    echo "✓ All tests and checks passed"
    exit 0
else
    echo "✗ Some tests or checks failed"
    exit 1
fi