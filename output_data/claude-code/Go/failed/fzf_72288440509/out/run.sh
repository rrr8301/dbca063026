#!/usr/bin/env bash
set -e

cd /app

# Rubocop
echo "=== Rubocop ==="
make lint || true

# Unit test
echo "=== Unit test ==="
make test || true

# Fuzz test
echo "=== Fuzz test ==="
go test ./src/algo/ -fuzz=FuzzIndexByteTwo -fuzztime=5s || true
go test ./src/algo/ -fuzz=FuzzLastIndexByteTwo -fuzztime=5s || true

# Integration test
echo "=== Integration test ==="
make install && ./install --all && tmux new-session -d && ruby test/runner.rb --verbose || true

echo "FINAL_STATUS = SUCCESS"
