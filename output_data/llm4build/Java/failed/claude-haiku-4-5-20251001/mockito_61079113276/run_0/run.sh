#!/bin/bash

set -e

# Print environment info
echo "=== Java Version ==="
java -version
echo ""
echo "=== Gradle Version ==="
./gradlew --version
echo ""

# Build on Java 11 with mock-maker-subclass and member-accessor-reflection
echo "=== Building with Java 11 (mock-maker-subclass, member-accessor-reflection) ==="
export MOCK_MAKER=mock-maker-subclass
export MEMBER_ACCESSOR=member-accessor-reflection
./gradlew \
    -Pmockito.test.java=11 \
    build \
    --stacktrace \
    --scan || BUILD_FAILED=1

# Generate coverage report
echo ""
echo "=== Generating Coverage Report ==="
./gradlew \
    -Pmockito.test.java=11 \
    coverageReport \
    --stacktrace \
    --scan || COVERAGE_FAILED=1

# Print coverage report location
echo ""
echo "=== Coverage Report Generated ==="
if [ -f "mockito-core/build/reports/jacoco/mockitoCoverage/mockitoCoverage.xml" ]; then
    echo "Coverage report available at: mockito-core/build/reports/jacoco/mockitoCoverage/mockitoCoverage.xml"
else
    echo "Warning: Coverage report not found at expected location"
fi

# Exit with failure if any step failed
if [ "$BUILD_FAILED" = "1" ] || [ "$COVERAGE_FAILED" = "1" ]; then
    echo ""
    echo "=== Build or Coverage Generation Failed ==="
    exit 1
fi

echo ""
echo "=== All Tests and Coverage Generation Completed Successfully ==="
exit 0