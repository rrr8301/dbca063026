#!/bin/bash

set -e

# Set up environment
export JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Set JDK17 for test execution (used by setup-test-jdk action)
export JDK17=/usr/lib/jvm/java-17-openjdk-amd64

# Optional: Set Develocity access key if provided
# export DEVELOCITY_ACCESS_KEY=${DEVELOCITY_ACCESS_KEY:-}

# Verify Java installation
echo "Java version:"
java -version

echo "Gradle version:"
./gradlew --version

# Run the build with the exact Gradle command from the workflow
# This replicates the run-gradle action step
echo "Running Gradle build..."
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

echo "Build completed successfully!"