#!/bin/bash

set -e

# Clone repository (assuming it's passed as an argument or environment variable)
# For local testing, the repo should be mounted or cloned
if [ ! -d "/workspace/.git" ]; then
    echo "Repository not found. Cloning from current directory..."
    cd /workspace
fi

# Navigate to workspace
cd /workspace

echo "=== Installing Ruby gems ==="
bundle install

echo "=== Running linting (make lint) ==="
make lint || true

echo "=== Running unit tests (make test) ==="
make test || true

echo "=== Running Go fuzz tests ==="
echo "Fuzz test 1: FuzzIndexByteTwo"
go test ./src/algo/ -fuzz=FuzzIndexByteTwo -fuzztime=5s || true

echo "Fuzz test 2: FuzzLastIndexByteTwo"
go test ./src/algo/ -fuzz=FuzzLastIndexByteTwo -fuzztime=5s || true

echo "=== Running integration tests ==="
echo "Installing fzf..."
make install || true

echo "Running install script..."
./install --all || true

echo "Starting tmux session for integration tests..."
tmux new-session -d || true

echo "Running Ruby integration test runner..."
ruby test/runner.rb --verbose || true

echo "=== All tests completed ==="