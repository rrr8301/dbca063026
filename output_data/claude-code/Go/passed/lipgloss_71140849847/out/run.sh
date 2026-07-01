#!/usr/bin/env bash
set -e

cd /app

# Configure git for charmbracelet access if GH_PAT is set
if [ -n "$GH_PAT" ]; then
  git config --global url."https://${GH_PAT}@github.com/charmbracelet".insteadOf "https://github.com/charmbracelet"
  git config --global url."https://${GH_PAT}@github.com/charmcli".insteadOf "https://github.com/charmcli"
fi

# Tidy Go modules
echo "Tidying Go modules..."
go mod tidy

# Check for changes
echo "Checking for changes..."
git diff --exit-code

# Build
echo "Building..."
go build ./...

# Test
echo "Testing..."
go test ./...

echo "FINAL_STATUS = SUCCESS"
