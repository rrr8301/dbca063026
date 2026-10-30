#!/bin/bash

# Install Go dependencies
go get -d -t ./...

# Run tests
make test