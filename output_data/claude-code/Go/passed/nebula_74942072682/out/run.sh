#!/usr/bin/env bash

set -e

echo "=== Build ==="
make all

echo "=== Vet ==="
make vet

echo "=== Test ==="
make test

echo "=== End 2 end ==="
make e2evv

echo "=== Build test mobile ==="
make build-test-mobile

echo "FINAL_STATUS = SUCCESS"
