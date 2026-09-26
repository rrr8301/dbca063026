#!/bin/bash

# Clone the repository
git clone https://github.com/ory/hydra.git /app
cd /app

# Setup HSM libs and packages
sudo rm -rf /var/lib/softhsm/tokens
sudo mkdir -p /var/lib/softhsm/tokens
sudo chmod -R a+rwx /var/lib/softhsm
sudo chmod a+rx /etc/softhsm
sudo chmod a+r /etc/softhsm/*

# Initialize HSM token
pkcs11-tool --module /usr/lib/softhsm/libsofthsm2.so --slot 0 --init-token --so-pin 0000 --init-pin --pin 1234 --label hydra

# Install Go dependencies
go mod download

# Run HSM tests
go test -p 1 -failfast -short -timeout=20m -tags=sqlite,hsm ./...