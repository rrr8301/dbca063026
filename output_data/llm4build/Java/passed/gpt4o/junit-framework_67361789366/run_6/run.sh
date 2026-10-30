#!/bin/bash

# Activate GraalVM environment
export JAVA_HOME=/opt/graalvm-ce-java11-21.3.0
export PATH="$JAVA_HOME/bin:$PATH"

# Install project dependencies
./gradlew --no-daemon build

# Run tests with specific Gradle arguments
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