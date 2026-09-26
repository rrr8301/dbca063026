#!/bin/bash
set -e

# Verify Go installation
go version

# Initialize HSM token
echo "Initializing HSM token..."
pkcs11-tool --module /usr/lib/softhsm/libsofthsm2.so --slot 0 --init-token --so-pin 0000 --init-pin --pin 1234 --label hydra

# Download Go dependencies
echo "Downloading Go dependencies..."
go mod download

# Run HSM tests
echo "Running HSM tests..."
go test -p 1 -failfast -short -timeout=20m -tags=sqlite,hsm ./...

echo "HSM tests completed successfully!"