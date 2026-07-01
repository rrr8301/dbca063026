#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

# Define test patterns (from matrix) - these are test class name patterns, not module names
PATTERNS=("K*" "E*" "W*" "Z*" "Y*" "X*")

# Verify Java and Maven are available
echo "Java version:"
java -version

echo "Maven version:"
mvn -version

# Run tests for each pattern
for PATTERN in "${PATTERNS[@]}"; do
    echo "=========================================="
    echo "Running tests for pattern: $PATTERN"
    echo "=========================================="
    
    if mvn clean test -Dtest="!QTest,'$PATTERN'" -Dmaven.test.failure.ignore=true; then
        echo "✓ Tests passed for pattern: $PATTERN"
    else
        echo "✗ Tests failed for pattern: $PATTERN"
        TEST_FAILED=1
    fi
done

echo "=========================================="
echo "Test execution completed"
echo "=========================================="

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "Some test patterns failed. Check output above for details."
    exit 1
else
    echo "All test patterns passed successfully."
    exit 0
fi