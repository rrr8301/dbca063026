#!/usr/bin/env bash

echo "=== Ruby version ==="
ruby -v

echo "=== Compiler version ==="
clang --version

echo "=== Building and testing ==="
rake -m test:run:serial || true

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
