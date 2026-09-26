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
# Modify this section to handle 'toolchain' and 'tool' directives gracefully
if grep -q 'toolchain' go.mod || grep -q 'tool' go.mod; then
  echo "^^^^ go.mod contains 'toolchain' or 'tool' directives. Handling gracefully."
  # Optionally, you can log this occurrence or take other actions as needed
fi

# Install goimports
go install golang.org/x/tools/cmd/goimports@v0.1.5

# Build the project
make && ./bin/akvorado version

# Run tests
make test-go  # Ensure all tests run