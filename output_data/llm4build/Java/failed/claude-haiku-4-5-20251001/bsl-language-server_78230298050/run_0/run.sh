#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Build and run tests with Gradle
./gradlew check --stacktrace