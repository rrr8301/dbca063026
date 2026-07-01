#!/bin/bash
set -e

# Run coverage tests as specified in the YAML workflow
echo "Running Go coverage tests..."
go version
GOPROXY="https://proxy.golang.org,direct" make go.test.coverage

echo "Coverage tests completed successfully!"