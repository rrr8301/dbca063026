#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go mod download

# Run tests
go test -v -parallel 8 github.com/traefik/traefik/v3/pkg/config/label github.com/traefik/traefik/v3/pkg/config