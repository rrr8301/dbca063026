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
  echo "^^^^ go.mod contains 'toolchain' or 'tool' directives. Removing them."
  sed -i '/^toolchain/d' go.mod
  sed -i '/^tool/d' go.mod
fi

# Install necessary tools separately
go install github.com/dmarkham/enumer@latest
go install github.com/frapposelli/wwhrd@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/mgechev/revive@latest
go install github.com/mna/pigeon@latest
go install github.com/planetscale/vtprotobuf/cmd/protoc-gen-go-vtproto@latest
go install go.uber.org/mock/mockgen@latest
go install golang.org/x/tools/cmd/goimports@v0.1.5
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install gotest.tools/gotestsum@latest
go install honnef.co/go/tools/cmd/staticcheck@latest

# Build the project
make && ./bin/akvorado version

# Run tests
make test-go