#!/bin/bash

# Ensure the script exits on any error
set -e

# Run the tests using the exact command from the YAML
./gradlew check --no-parallel --no-daemon --console=plain