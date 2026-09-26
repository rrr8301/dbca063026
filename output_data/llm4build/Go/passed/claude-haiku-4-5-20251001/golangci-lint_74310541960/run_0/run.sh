#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Verify Go installation
go version

# Run tests using the exact command from the YAML
make test