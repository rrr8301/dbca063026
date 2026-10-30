#!/bin/bash

set -e

# Navigate to the repository root
cd /workspace

# Build with Maven (exact command from YAML)
mvn --errors --show-version --batch-mode --no-transfer-progress -Ddoclint=all -Drat.skip=true -Dlicense.skip=true

echo "Build completed successfully!"