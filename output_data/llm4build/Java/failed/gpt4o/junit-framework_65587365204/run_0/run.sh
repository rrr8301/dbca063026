#!/bin/bash

# Activate GraalVM
export PATH=/opt/graalvm-ce-java21-21.3.0/bin:$PATH

# Activate JDK 25
export PATH=/opt/jdk-25/bin:$PATH

# Install project dependencies and build
./gradlew build

# Run tests
./gradlew :platform-tooling-support-tests:test --continue