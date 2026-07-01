#!/bin/bash

set -e

# Print Go version for verification
go version

# Run the test-race target from Makefile
make test-race