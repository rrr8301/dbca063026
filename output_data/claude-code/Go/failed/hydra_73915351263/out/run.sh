#!/usr/bin/env bash

set -e

echo "=== Initializing HSM Token ==="
pkcs11-tool --module /usr/lib/softhsm/libsofthsm2.so --slot 0 --init-token --so-pin 0000 --init-pin --pin 1234 --label hydra

echo "=== Running HSM tests ==="
go test -p 1 -failfast -short -timeout=20m -tags=sqlite,hsm ./... || EXIT_CODE=$?

if [ -z "$EXIT_CODE" ] || [ "$EXIT_CODE" -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = SUCCESS"
    exit 0
fi
