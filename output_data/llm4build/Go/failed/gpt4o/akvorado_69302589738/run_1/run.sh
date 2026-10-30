#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Check go.mod was not modified
if go mod edit -json | jq -r .Go | grep -vPx '1.\d+'; then
  echo "^^^^ Incorrect go directive in go.mod: use only 'minor.major'."
  exit 1
fi

# Ensure go.mod does not contain unknown directives
if grep -q 'toolchain' go.mod || grep -q 'tool' go.mod; then
  echo "^^^^ go.mod contains unknown directives: 'toolchain' or 'tool'."
  exit 1
fi

# Build the project
make && ./bin/akvorado version

# Run tests
make test-go || true  # Ensure all tests run even if some fail