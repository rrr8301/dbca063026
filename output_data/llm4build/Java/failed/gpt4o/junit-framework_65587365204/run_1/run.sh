#!/bin/bash

# Activate GraalVM
export PATH=/opt/graalvm-ce-java11-21.3.0/bin:$PATH

# Activate OpenJDK 17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Install project dependencies and build
./gradlew build

# Run tests
./gradlew :platform-tooling-support-tests:test --continue