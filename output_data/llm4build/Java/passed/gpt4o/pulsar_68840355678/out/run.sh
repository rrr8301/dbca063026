#!/bin/bash

# Activate environment variables if needed
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Install project dependencies
./gradlew assemble

# Run setup commands
./pulsar-build/run_integration_group_gradle.sh SHADE_BUILD

# Run integration test group
./pulsar-build/run_integration_group_gradle.sh SHADE_RUN

# Ensure all tests are executed
set +e
./gradlew test
set -e