#!/bin/bash

set -e

# Set up environment variables for JDKs
export JAVA_HOME=/opt/graalvm
export JDK17=/opt/jdk17
export JDK25=/opt/jdk25
export PATH=$JAVA_HOME/bin:$PATH

# Verify Java installations
echo "=== Java Versions ==="
java -version
$JDK17/bin/java -version

# Check if JDK25 exists before trying to use it
if [ -d "$JDK25" ] && [ -f "$JDK25/bin/java" ]; then
    $JDK25/bin/java -version
else
    echo "Warning: JDK 25 not found at $JDK25, skipping version check"
fi

# Navigate to workspace
cd /workspace

# Make Gradle wrapper executable
chmod +x ./gradlew

# Run the build with the specified arguments
# This includes platform-tooling-support-tests:test, build, jacocoRootReport
echo "=== Starting Gradle Build ==="
./gradlew \
  -Dorg.gradle.java.installations.auto-download=false \
  -Pjunit.develocity.buildCache.pushEnabled=false \
  -Pjunit.develocity.predictiveTestSelection.enabled=false \
  -Pjunit.develocity.predictiveTestSelection.selectRemainingTests=true \
  "-Dscan.value.GitHub job=Linux" \
  javaToolchains \
  :platform-tooling-support-tests:test \
  build \
  jacocoRootReport \
  --no-configuration-cache

# Generate test reports summary
echo "=== Build Complete ==="
echo "Build and tests completed successfully."
exit 0