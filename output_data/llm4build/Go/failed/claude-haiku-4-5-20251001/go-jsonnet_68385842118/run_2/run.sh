#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an argument or we're already in the repo)
# If running in a pre-cloned repo, this step can be skipped
if [ ! -f "go.mod" ]; then
    echo "Repository not found. Cloning..."
    git clone https://github.com/google/go-jsonnet.git /workspace
    cd /workspace
fi

cd /workspace

# Verify Go installation
echo "Go version:"
go version

# Verify Python installation
echo "Python version:"
python3 --version

# Upgrade pip and install Python packages
echo "Installing Python packages..."
pip install -U wheel
pip install -U pytest setuptools

# Install project dependencies
echo "Installing project dependencies..."
make install.dependencies

# Run tests with required environment variables
echo "Running tests..."
export GOARCH=amd64
export CGO_ENABLED=1
export SKIP_PYTHON_BINDINGS_TESTS=0

# Run make test and capture exit code but continue
make test || TEST_EXIT_CODE=$?

# Exit with the test result code if tests failed
if [ ! -z "$TEST_EXIT_CODE" ]; then
    exit $TEST_EXIT_CODE
fi

echo "All tests completed successfully!"
exit 0