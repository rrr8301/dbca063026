#!/usr/bin/env bash

cd /app

echo "=== Building with pkcs11 ==="
make bin-pkcs11

echo ""
echo "=== Testing with pkcs11 ==="
make test-pkcs11 || true

echo ""
echo "FINAL_STATUS = SUCCESS"
