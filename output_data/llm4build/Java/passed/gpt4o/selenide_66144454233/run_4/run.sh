#!/bin/bash

# Ensure the script exits on any error
set -e

# Navigate to the workspace directory
cd /workspace

# Run the tests using the exact command from the YAML
./gradlew check --no-parallel --no-daemon --console=plain