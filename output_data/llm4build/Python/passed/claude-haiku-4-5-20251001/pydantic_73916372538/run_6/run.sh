#!/bin/bash
set -e

# Set environment variables
export COLUMNS=150
export UV_FROZEN=true
export FORCE_COLOR=1
export UV_PYTHON_PREFERENCE=system
export COVERAGE_FILE=coverage/.coverage.Linux-py3.12
export CONTEXT=Linux-py3.12-without-deps

# Source Rust environment
. $HOME/.cargo/env

# Verify pyproject.toml exists
if [ ! -f "pyproject.toml" ]; then
    echo "Error: pyproject.toml not found in current directory"
    exit 1
fi

# Verify Python 3.12 is available
echo "Verifying Python 3.12..."
python --version

# Verify Rust is available
echo "Verifying Rust..."
rustc --version
cargo --version

# Sync dependencies with uv
echo "Installing project dependencies..."
uv sync --all-packages --group testing-extra --all-extras

# Verify pydantic version
echo "Verifying pydantic installation..."
uv run python -c "import pydantic.version; print(pydantic.version.version_info())"

# Create coverage directory
mkdir -p coverage

# Run tests
echo "Running tests..."
make test NUM_THREADS=1

echo "Tests completed successfully!"