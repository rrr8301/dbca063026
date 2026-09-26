#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Remove unsupported directives from go.mod
sed -i '/^toolchain/d' go.mod
sed -i '/^tool/d' go.mod

# Check go.mod file
if ! go mod edit -json | jq -r .Go | grep -qP '^1\.\d+$'; then
  echo "^^^^ Incorrect go directive in go.mod: use only 'minor.major'."
  exit 1
fi

# Ensure go.mod is tidy
if ! go mod tidy; then
  echo "go mod tidy failed."
  exit 1
fi

# Build the project
if ! make; then
  echo "Build failed."
  exit 1
fi

# Check if the binary exists before running
if [ -f "./bin/akvorado" ]; then
  ./bin/akvorado version
else
  echo "Binary ./bin/akvorado not found."
  exit 1
fi

# Run tests
if ! make test-go; then
  echo "Some tests failed."
  exit 1
fi