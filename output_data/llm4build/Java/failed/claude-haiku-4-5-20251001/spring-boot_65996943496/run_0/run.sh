#!/bin/bash

set -e

# Enable error handling: continue on test failures but report them
TEST_FAILED=0

echo "=========================================="
echo "Spring Boot Build and Test"
echo "=========================================="

# Verify Java installation
echo "Java version:"
java -version

echo ""
echo "=========================================="
echo "Building Spring Boot with Gradle"
echo "=========================================="

# Run Gradle build (includes compilation and tests)
# The 'build' task runs all tests and generates reports
if ./gradlew build; then
    echo "Build completed successfully"
else
    echo "Build failed"
    TEST_FAILED=1
fi

echo ""
echo "=========================================="
echo "Build Summary"
echo "=========================================="

if [ $TEST_FAILED -eq 0 ]; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi