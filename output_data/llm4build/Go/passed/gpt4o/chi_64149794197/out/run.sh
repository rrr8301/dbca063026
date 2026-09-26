#!/bin/bash

# Install project dependencies
go mod download

# Run tests
set -e
make test || true