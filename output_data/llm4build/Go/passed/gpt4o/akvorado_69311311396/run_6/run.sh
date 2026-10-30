#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Check go.mod file
if ! go mod edit -json | jq -r .Go | grep -qP '^1\.\d+$'; then
  echo "^^^^ Incorrect go directive in go.mod: use only 'minor.major'."
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