#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

# Define modules to test (from matrix)
MODULES=("K*" "E*" "W*" "Z*" "Y*" "X*")

# Verify Java and Maven are available
echo "Java version:"
java -version

echo "Maven version:"
mvn -version

# Run tests for each module
for MODULE in "${MODULES[@]}"; do
    echo "=========================================="
    echo "Running tests for module: $MODULE"
    echo "=========================================="
    
    if mvn clean test -pl "$MODULE" -Dmaven.test.failure.ignore=true; then
        echo "✓ Tests passed for module: $MODULE"
    else
        echo "✗ Tests failed for module: $MODULE"
        TEST_FAILED=1
    fi
done

echo "=========================================="
echo "Test execution completed"
echo "=========================================="

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "Some test modules failed. Check output above for details."
    exit 1
else
    echo "All test modules passed successfully."
    exit 0
fi