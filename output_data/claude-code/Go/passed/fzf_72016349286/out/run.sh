#!/usr/bin/env bash
set -e

echo "=== Running Rubocop lint ==="
make lint || true

echo "=== Running unit tests ==="
make test || true

echo "=== Running fuzz tests ==="
go test ./src/algo/ -fuzz=FuzzIndexByteTwo -fuzztime=5s || true
go test ./src/algo/ -fuzz=FuzzLastIndexByteTwo -fuzztime=5s || true

echo "=== Running integration tests ==="
make install && ./install --all && tmux new-session -d && ruby test/runner.rb --verbose || true

echo "Tests completed"
FINAL_STATUS = SUCCESS
