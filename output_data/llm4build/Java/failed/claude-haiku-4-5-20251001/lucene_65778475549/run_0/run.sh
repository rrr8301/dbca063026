#!/bin/bash

set -e

# Print Java version for diagnostics
echo "=== Java Version ==="
java -version

# Print Gradle version
echo "=== Gradle Version ==="
./gradlew --version

# Display Gradle diagnostics
echo "=== Gradle Diagnostics ==="
./gradlew displayGradleDiagnostics

# Run all tests with specified options
echo "=== Running Tests ==="
./gradlew allOptions test \
  -Ptask.times=true \
  -Pvalidation.errorprone=false \
  -DTEST_JVM_ARGS="-XX:TieredStopAtLevel=1 -XX:+UseParallelGC -XX:ActiveProcessorCount=1" \
  || TEST_FAILED=true

# List gradle.properties for verification
echo "=== Gradle Properties ==="
cat gradle.properties

# Exit with failure if tests failed
if [ "$TEST_FAILED" = true ]; then
  echo "Tests failed!"
  exit 1
fi

echo "=== All Tests Passed ==="
exit 0