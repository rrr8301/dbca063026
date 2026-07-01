#!/bin/bash
set -e

# Install tools from the project
echo "Installing tools..."
go install ./cmd/...

echo "Setup complete. Ready for tests."