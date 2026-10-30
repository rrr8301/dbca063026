#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Verify repository exists
if [ ! -f "Gemfile" ]; then
    echo "Error: Gemfile not found in /workspace"
    echo "Please ensure the repository is mounted or cloned to /workspace"
    exit 1
fi

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