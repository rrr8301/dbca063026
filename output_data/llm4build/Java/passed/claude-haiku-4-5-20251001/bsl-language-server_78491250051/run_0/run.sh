#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run Gradle build with tests
./gradlew check --stacktrace