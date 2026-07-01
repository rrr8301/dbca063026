#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Print Go version
go version

# Check if the replacement path is necessary
if grep -q "replace github.com/envoyproxy/go-control-plane" go.mod; then
  echo "The go.mod file contains a replacement for github.com/envoyproxy/go-control-plane."
  echo "Ensure the path ./external/go-control-plane exists or adjust the go.mod file."
  # Create the directory if it doesn't exist
  mkdir -p ./external/go-control-plane
  # Optionally, you can clone the repository if needed
  # git clone https://github.com/envoyproxy/go-control-plane.git ./external/go-control-plane
fi

# Check if the replacement path for hgctl is necessary
if grep -q "replace github.com/alibaba/higress/hgctl" go.mod; then
  echo "The go.mod file contains a replacement for github.com/alibaba/higress/hgctl."
  echo "Ensure the path ./hgctl exists or adjust the go.mod file."
  # Create the directory if it doesn't exist
  mkdir -p ./hgctl
  # Optionally, you can clone the repository if needed
  # git clone https://github.com/alibaba/higress.git ./hgctl
fi

# Install Go dependencies
go mod tidy

# Run coverage tests
make go.test.coverage

# Ensure all tests are executed
echo "All tests executed successfully."