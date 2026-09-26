#!/bin/bash

set -e

# Enable error handling: continue on test failures but track them
TEST_FAILED=0

# Print Java version for verification
echo "=== Java Version ==="
java -version
echo ""

# Print Maven version
echo "=== Maven Version ==="
./mvnw -version
echo ""

# Create logs directory
LOGS_DIR="/tmp/fluss-logs"
mkdir -p "$LOGS_DIR"

# Define modules to test
MODULES=("core" "flink" "spark3" "lake")

# Set Maven options
export MAVEN_OPTS="-Xmx4096m"

# Set placeholder environment variables for artifacts (if needed)
# These would normally come from GitHub secrets; set to empty for local testing
export ARTIFACTS_OSS_ENDPOINT="${ARTIFACTS_OSS_ENDPOINT:-}"
export ARTIFACTS_OSS_REGION="${ARTIFACTS_OSS_REGION:-}"
export ARTIFACTS_OSS_BUCKET="${ARTIFACTS_OSS_BUCKET:-}"
export ARTIFACTS_OSS_ACCESS_KEY="${ARTIFACTS_OSS_ACCESS_KEY:-}"
export ARTIFACTS_OSS_SECRET_KEY="${ARTIFACTS_OSS_SECRET_KEY:-}"
export ARTIFACTS_OSS_STS_ENDPOINT="${ARTIFACTS_OSS_STS_ENDPOINT:-}"
export ARTIFACTS_OSS_ROLE_ARN="${ARTIFACTS_OSS_ROLE_ARN:-}"

echo "=== Building Project ==="
./mvnw -T 1C -B clean install -DskipTests
echo "Build completed successfully"
echo ""

# Test each module
for MODULE in "${MODULES[@]}"; do
    echo "=========================================="
    echo "Testing module: $MODULE"
    echo "=========================================="
    
    # Get test modules using the stage.sh script
    TEST_MODULES=$(./.github/workflows/stage.sh "$MODULE")
    echo "Test modules for $MODULE: $TEST_MODULES"
    
    # Run tests with timeout
    if timeout 3600 ./mvnw -B verify $TEST_MODULES \
        -Ptest-coverage \
        -Ptest-"$MODULE" \
        -Dlog.dir="$LOGS_DIR" \
        -Dlog4j.configurationFile="$(pwd)/tools/ci/log4j.properties"; then
        echo "✓ Tests passed for module: $MODULE"
    else
        TEST_EXIT_CODE=$?
        echo "✗ Tests failed for module: $MODULE (exit code: $TEST_EXIT_CODE)"
        TEST_FAILED=1
    fi
    echo ""
done

# Print summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Logs directory: $LOGS_DIR"
if [ -d "fluss-test-coverage/target/site/jacoco-aggregate" ]; then
    echo "JaCoCo coverage report: $(pwd)/fluss-test-coverage/target/site/jacoco-aggregate"
fi

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "Some tests failed. See details above."
    exit 1
else
    echo "All tests passed!"
    exit 0
fi