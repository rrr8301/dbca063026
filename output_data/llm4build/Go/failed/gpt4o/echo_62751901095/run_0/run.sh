#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app

# Change to the app directory
cd /app

# Install Go dependencies
go mod tidy

# Run tests
go test -race --coverprofile=coverage.coverprofile --covermode=atomic ./...