#!/bin/bash

# Print Go version
go version

# Run tests
go test -shuffle=on ./...
go test -race -shuffle=on ./...