#!/usr/bin/env bash

set -e

cd /app

# Print Java versions
echo "=== Java Versions ==="
java -version
echo "JDK17: $JDK17"
echo "JDK21: $JDK21"
echo "JDK24: $JDK24"
echo "JDK25: $JDK25"
echo "GRAALVM_HOME: $GRAALVM_HOME"

# Run the build with the exact same commands as the GitHub Actions
echo "=== Running Gradle Build ==="

./gradlew \
  -Dorg.gradle.java.installations.auto-download=false \
  -Pjunit.develocity.buildCache.pushEnabled=false \
  -Pjunit.develocity.predictiveTestSelection.enabled=true \
  -Pjunit.develocity.predictiveTestSelection.selectRemainingTests=true \
  "-Dscan.value.GitHub job=Linux" \
  javaToolchains \
  :platform-tooling-support-tests:test \
  build \
  jacocoRootReport \
  --no-configuration-cache

echo "FINAL_STATUS = SUCCESS"
