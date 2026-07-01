#!/bin/bash

set -e

# Activate Python 3.8 environment (ensure it's the default)
export PYTHON_VERSION=3.8

# Navigate to workspace
cd /workspace

# Display environment info
echo "=== Environment Info ==="
java -version
mvn -version
python3.8 --version
node --version
npm --version
go version
rustc --version
cargo --version
echo "========================"

# Run the CI script with Java 17
echo "Running CI with Maven for Java 17..."
python3.8 ./ci/run_ci.py java --version 17

echo "CI execution completed successfully!"