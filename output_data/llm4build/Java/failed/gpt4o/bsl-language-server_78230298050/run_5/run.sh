#!/bin/bash

# Activate SDKMAN
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Navigate to the workspace
cd /workspace

# Build with Gradle
./gradlew check --stacktrace