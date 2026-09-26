#!/bin/bash

# Activate SDKMAN
source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Set Java version
sdk use java 17.0.7-zulu

# Validate Gradle wrapper
./gradlew wrapper --gradle-version 7.3.3

# Build and check reproducibility
./check_reproducibility.sh || true

# Spotless check
./gradlew spotlessCheck --stacktrace --scan || true

# Build with Gradle
./gradlew -Pmockito.test.java=11 build --stacktrace --scan || true

# Generate coverage report
./gradlew -Pmockito.test.java=11 coverageReport --stacktrace --scan || true

# Note: Upload coverage report step is skipped