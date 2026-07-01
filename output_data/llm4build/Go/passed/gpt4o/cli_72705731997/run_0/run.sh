#!/bin/bash

# Download Go dependencies
go mod download

# Run unit and integration tests
go test -race -tags=integration ./...

# Build the project
go build -v ./cmd/gh