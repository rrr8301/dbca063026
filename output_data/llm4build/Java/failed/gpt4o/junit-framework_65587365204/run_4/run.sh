#!/bin/bash

# Activate OpenJDK 17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Ensure Gradle uses the correct Java version
export GRADLE_OPTS="-Dorg.gradle.java.installations.auto-download=false"

# Install project dependencies and build
./gradlew build

# Run tests
./gradlew :platform-tooling-support-tests:test --continue