#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Build with Maven
# Using exact command from YAML with RAT and license checks skipped for build artifacts
mvn --errors --show-version --batch-mode --no-transfer-progress -Ddoclint=all -Drat.skip=true -Dlicense.skip=true

echo "Build completed successfully!"