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
make lint

echo "=== Running unit tests (make test) ==="
make test

echo "=== Running Go fuzz tests ==="
echo "Fuzz test 1: FuzzIndexByteTwo"
go test ./src/algo/ -fuzz=FuzzIndexByteTwo -fuzztime=5s

echo "Fuzz test 2: FuzzLastIndexByteTwo"
go test ./src/algo/ -fuzz=FuzzLastIndexByteTwo -fuzztime=5s

echo "=== Running integration tests ==="
echo "Installing fzf..."
make install

echo "Running install script..."
./install --all

echo "Starting tmux session for integration tests..."
tmux new-session -d

echo "Running Ruby integration test runner..."
ruby test/runner.rb --verbose

echo "=== All tests completed ==="