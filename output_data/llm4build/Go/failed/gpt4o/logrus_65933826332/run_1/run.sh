#!/bin/bash

# Clone the repository
git clone https://github.com/your/repository.git /app
cd /app

# Run tests
go test -race -v ./...