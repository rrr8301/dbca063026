#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Verify Go installation
go version

# Run the build step (exact command from YAML)
echo "Build job completed"

echo "Build completed successfully"