#!/bin/bash

# Clone the repository
git clone <repository-url> /app
cd /app

# Run tests
go test -race -v ./...