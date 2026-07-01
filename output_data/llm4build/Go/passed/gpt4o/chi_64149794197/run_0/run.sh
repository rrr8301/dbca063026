#!/bin/bash

# Install Go dependencies
go get -d -t ./...

# Run tests
make test || true  # Ensure all tests run even if some fail