#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Run Maven build and tests with RAT and license checks skipped
# The -B flag runs in batch mode (non-interactive)
# -Drat.skip=true and -Dlicense.skip=true prevent false failures from build artifacts
mvn -B package --file pom.xml -Drat.skip=true -Dlicense.skip=true

echo "Build and tests completed successfully."