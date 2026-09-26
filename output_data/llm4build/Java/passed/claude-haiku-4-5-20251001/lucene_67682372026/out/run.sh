#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Display Java version for verification
echo "=== Java Version ==="
java -version
echo ""

# Display Gradle version
echo "=== Gradle Version ==="
./gradlew --version
echo ""

# Run gradle tests with the exact command from the YAML
echo "=== Running Gradle Tests ==="
./gradlew displayGradleDiagnostics allOptions test "-Ptask.times=true" "-Pvalidation.errorprone=false" \
  -DTEST_JVM_ARGS="-XX:TieredStopAtLevel=1 -XX:+UseParallelGC -XX:ActiveProcessorCount=1"

# List automatically-initialized gradle.properties
echo ""
echo "=== Gradle Properties ==="
cat gradle.properties