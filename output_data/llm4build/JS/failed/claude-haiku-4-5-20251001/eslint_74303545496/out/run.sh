#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run tests using the exact command from the YAML
node Makefile mocha

echo "Tests completed successfully"