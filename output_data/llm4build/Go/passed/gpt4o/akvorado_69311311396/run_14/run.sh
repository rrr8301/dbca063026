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

# Install necessary tools, skipping the problematic package
go install github.com/frapposelli/wwhrd@latest \
    && go install github.com/planetscale/vtprotobuf/cmd/protoc-gen-go-vtproto@latest \
    && go install go.uber.org/mock/mockgen@latest \
    && go install golang.org/x/tools/cmd/goimports@latest \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest \
    && go install gotest.tools/gotestsum@latest \
    && go install honnef.co/go/tools/cmd/staticcheck@latest

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