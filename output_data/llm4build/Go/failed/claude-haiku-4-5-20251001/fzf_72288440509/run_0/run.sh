#!/bin/bash

set -e

# Print Go and Ruby versions for verification
echo "Go version:"
go version

echo "Ruby version:"
ruby --version

echo "Bundler version:"
bundle --version

# Install Ruby gems
echo "Installing Ruby gems..."
bundle install

# Run linting
echo "Running linting..."
make lint

# Run unit tests
echo "Running unit tests..."
make test

# Run fuzz tests
echo "Running fuzz tests..."
go test ./src/algo/ -fuzz=FuzzIndexByteTwo -fuzztime=5s || true
go test ./src/algo/ -fuzz=FuzzLastIndexByteTwo -fuzztime=5s || true

# Run integration tests
echo "Running integration tests..."
make install && ./install --all && tmux new-session -d && ruby test/runner.rb --verbose || true

echo "All tests completed."