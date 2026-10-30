#!/bin/bash

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

# Install Go dependencies
go mod tidy

# Run HSM tests
go test -p 1 -failfast -short -timeout=20m -tags=sqlite,hsm ./...