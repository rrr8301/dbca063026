#!/bin/bash
set -e

# Load environment variables from .github/env
if [ -f ".github/env" ]; then
    export $(cat ".github/env" | xargs)
fi

# Verify Go installation
go version

# Test source headers are present
make test-source-headers

# Check if go modules need to be tidied
go mod tidy -diff

# Run unit tests with coverage
make test-coverage