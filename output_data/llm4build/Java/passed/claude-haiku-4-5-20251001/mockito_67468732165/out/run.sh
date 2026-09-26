#!/bin/bash

set -e

# Print commands for debugging
set -x

# Set environment variables for the build
export MOCK_MAKER=mock-maker-inline
export MEMBER_ACCESSOR=member-accessor-module
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "=========================================="
echo "Java version check"
echo "=========================================="
java -version
javac -version

echo "=========================================="
echo "Building Mockito with Java 11 tests"
echo "=========================================="
./gradlew \
  -Pmockito.test.java=11 \
  build \
  --stacktrace \
  --scan || BUILD_FAILED=1

echo "=========================================="
echo "Generating coverage report"
echo "=========================================="
./gradlew \
  -Pmockito.test.java=11 \
  coverageReport \
  --stacktrace \
  --scan || COVERAGE_FAILED=1

echo "=========================================="
echo "Coverage report generated"
echo "=========================================="
if [ -f mockito-core/build/reports/jacoco/mockitoCoverage/mockitoCoverage.xml ]; then
  echo "Coverage report found at: mockito-core/build/reports/jacoco/mockitoCoverage/mockitoCoverage.xml"
  ls -lh mockito-core/build/reports/jacoco/mockitoCoverage/mockitoCoverage.xml
else
  echo "Warning: Coverage report not found"
fi

echo "=========================================="
echo "Build Summary"
echo "=========================================="
if [ -z "$BUILD_FAILED" ] && [ -z "$COVERAGE_FAILED" ]; then
  echo "✓ All tasks completed successfully"
  exit 0
else
  echo "✗ Some tasks failed"
  [ -n "$BUILD_FAILED" ] && echo "  - Build failed"
  [ -n "$COVERAGE_FAILED" ] && echo "  - Coverage report generation failed"
  exit 1
fi