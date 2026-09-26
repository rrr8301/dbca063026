#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Run Gradle build (exact command from YAML)
./gradlew build