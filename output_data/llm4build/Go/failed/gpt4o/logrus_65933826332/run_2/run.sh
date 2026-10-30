#!/bin/bash

# Clone the repository into a subdirectory
git clone https://github.com/your/repository.git /app/repo
cd /app/repo

# Run tests
go test -race -v ./...