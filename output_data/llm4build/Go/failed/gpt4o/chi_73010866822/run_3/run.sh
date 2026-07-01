#!/bin/bash

# Install Go dependencies
go mod tidy
go mod download

# Run tests
make test