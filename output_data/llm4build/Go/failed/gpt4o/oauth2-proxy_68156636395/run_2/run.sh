#!/bin/bash

# Clone the repository
git clone <actual-repository-url> /app
cd /app

# Get Go version from go.mod
version=$(grep "^go " go.mod | cut -d' ' -f2 | cut -d. -f1,2)

# Set up Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Verify code generation
make verify-generate

# Lint the code
make lint

# Build the project if not a release branch
if [[ ! $GITHUB_HEAD_REF =~ ^release ]]; then
    make build
fi

# Run tests with CGO enabled
export CGO_ENABLED=1
COVER=true make test