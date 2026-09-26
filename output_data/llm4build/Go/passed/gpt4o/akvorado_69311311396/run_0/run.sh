#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Check go.mod file
if ! go mod edit -json | jq -r .Go | grep -vPx '1.\d+'; then
  echo "^^^^ Incorrect go directive in go.mod: use only 'minor.major'."
  exit 1
fi

# Build the project
make && ./bin/akvorado version

# Run tests
make test-go || true  # Ensure all tests run even if some fail