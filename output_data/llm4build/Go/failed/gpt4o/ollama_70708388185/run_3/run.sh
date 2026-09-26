#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the app directory
cd /app

# Run go generate
go generate ./...

# Run go tests
go test -count=1 -benchtime=1x ./...