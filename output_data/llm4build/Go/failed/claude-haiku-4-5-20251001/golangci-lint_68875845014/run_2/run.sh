#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Download Go module dependencies
go mod download

# Run tests using the exact command from the YAML
make test