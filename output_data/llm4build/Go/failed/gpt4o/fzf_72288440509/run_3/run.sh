#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
make install

# Run linting
make lint

# Run unit tests
make test

# Run fuzz tests
go test ./src/algo/ -fuzz=FuzzIndexByteTwo -fuzztime=5s
go test ./src/algo/ -fuzz=FuzzLastIndexByteTwo -fuzztime=5s

# Run integration tests
make install && ./install --all && tmux new-session -d && ruby test/runner.rb --verbose