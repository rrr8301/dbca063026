#!/bin/bash
set -e

# Print Go version for verification
go version

# Run coverage tests
GOPROXY="https://proxy.golang.org,direct" make go.test.coverage

echo "Coverage tests completed successfully"