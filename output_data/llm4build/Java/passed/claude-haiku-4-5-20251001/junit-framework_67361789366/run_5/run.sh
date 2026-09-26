#!/bin/bash
set -e

# Activate environment - use JDK 21 for Gradle (JDK 25 not yet available in stable releases)
export JAVA_HOME=/opt/jdk21
export PATH=/opt/jdk21/bin:$PATH
export JDK17=/opt/jdk17
export JDK21=/opt/jdk21

# Ensure we're in the workspace
cd /workspace

# Make gradlew executable
chmod +x ./gradlew

# Run Gradle with the exact arguments from the CI job
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

echo "Build and tests completed successfully!"