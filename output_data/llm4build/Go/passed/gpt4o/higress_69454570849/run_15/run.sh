#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Print Go version
go version

# Function to set up replacement paths
setup_replacements() {
  # Check if the replacement path is necessary for go-control-plane
  if grep -q "replace github.com/envoyproxy/go-control-plane" go.mod; then
    echo "The go.mod file contains a replacement for github.com/envoyproxy/go-control-plane."
    echo "Ensure the path ./external/go-control-plane exists or adjust the go.mod file."
    # Create the directory if it doesn't exist
    mkdir -p ./external/go-control-plane
    # Clone the repository if needed
    if [ ! -d "./external/go-control-plane/.git" ]; then
      git clone https://github.com/envoyproxy/go-control-plane.git ./external/go-control-plane
    fi
  fi

  # Check if the replacement path for hgctl is necessary
  if grep -q "replace github.com/alibaba/higress/hgctl" go.mod; then
    echo "The go.mod file contains a replacement for github.com/alibaba/higress/hgctl."
    echo "Ensure the path ./hgctl exists or adjust the go.mod file."
    # Create the directory if it doesn't exist
    mkdir -p ./hgctl
    # Clone the repository if needed
    if [ ! -d "./hgctl/.git" ]; then
      if [ -z "$(ls -A ./hgctl)" ]; then
        git clone https://github.com/alibaba/higress.git ./hgctl
      else
        echo "Directory ./hgctl is not empty, skipping clone."
      fi
    fi
  fi

  # Check if the replacement path for api is necessary
  if grep -q "replace istio.io/api" go.mod; then
    echo "The go.mod file contains a replacement for istio.io/api."
    echo "Ensure the path ./external/api exists or adjust the go.mod file."
    # Create the directory if it doesn't exist
    mkdir -p ./external/api
    # Clone the repository if needed
    if [ ! -d "./external/api/.git" ]; then
      git clone https://github.com/istio/api.git ./external/api
    fi
  fi

  # Check if the replacement path for client-go is necessary
  if grep -q "replace istio.io/client-go" go.mod; then
    echo "The go.mod file contains a replacement for istio.io/client-go."
    echo "Ensure the path ./external/client-go exists or adjust the go.mod file."
    # Create the directory if it doesn't exist
    mkdir -p ./external/client-go
    # Clone the repository if needed
    if [ ! -d "./external/client-go/.git" ]; then
      git clone https://github.com/istio/client-go.git ./external/client-go
    fi
  fi

  # Check if the replacement path for istio is necessary
  if grep -q "replace istio.io/istio" go.mod; then
    echo "The go.mod file contains a replacement for istio.io/istio."
    echo "Ensure the path ./external/istio exists or adjust the go.mod file."
    # Create the directory if it doesn't exist
    mkdir -p ./external/istio
    # Clone the repository if needed
    if [ ! -d "./external/istio/.git" ]; then
      git clone https://github.com/istio/istio.git ./external/istio
    fi
  fi
}

# If the first argument is 'setup', run the setup function and exit
if [ "$1" == "setup" ]; then
  setup_replacements
  exit 0
fi

# Install Go dependencies
go mod tidy

# Run coverage tests
make go.test.coverage

# Ensure all tests are executed
echo "All tests executed successfully."