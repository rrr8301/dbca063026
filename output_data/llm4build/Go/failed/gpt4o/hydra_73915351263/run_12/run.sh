#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Setup HSM libs and packages
rm -rf /var/lib/softhsm/tokens
mkdir -p /var/lib/softhsm/tokens
chmod -R a+rwx /var/lib/softhsm
chmod a+rx /etc/softhsm
chmod a+r /etc/softhsm/*

# Initialize HSM token
pkcs11-tool --module /usr/lib/softhsm/libsofthsm2.so --slot 0 --init-token --so-pin 0000 --init-pin --pin 1234 --label hydra

# Ensure Go modules are initialized
if [ ! -f go.mod ]; then
    go mod init
fi

# Validate and tidy Go modules
go mod tidy || true

# Check for syntax errors in go.mod
if ! go mod verify; then
    echo "Error: go.mod contains syntax errors."
    exit 1
fi

# Run HSM tests
go test -p 1 -failfast -short -timeout=20m -tags=sqlite,hsm ./...