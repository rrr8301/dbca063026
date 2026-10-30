#!/bin/bash

set -e

# Enable error handling: continue on test failures but report them
TEST_FAILED=0

echo "=========================================="
echo "Jackson Databind Build and Test"
echo "=========================================="

# Display Java version
echo "Java version:"
java -version

echo ""
echo "=========================================="
echo "Building project with Maven..."
echo "=========================================="

# Run Maven verify goal (includes compile, test, package, verify)
# -B: batch mode (non-interactive)
# -ff: fail fast (stop on first failure in reactor)
# -ntp: no transfer progress (cleaner output)
if ./mvnw -B -ff -ntp verify; then
    echo "Build and tests completed successfully!"
else
    TEST_FAILED=1
    echo "Build or tests failed!"
fi

echo ""
echo "=========================================="
echo "Extracting project version..."
echo "=========================================="

# Extract project Maven version
PROJECT_VERSION=$(./mvnw org.apache.maven.plugins:maven-help-plugin:3.5.1:evaluate -DforceStdout -Dexpression=project.version -q)
echo "Project version: $PROJECT_VERSION"

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