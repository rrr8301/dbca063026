#!/bin/bash
set -e

# Set environment variables
export COLUMNS=150
export UV_FROZEN=true
export FORCE_COLOR=1
export UV_PYTHON_PREFERENCE=only-managed
export COVERAGE_FILE=coverage/.coverage.Linux-py3.12
export CONTEXT=Linux-py3.12-without-deps
export UV_PYTHON_DOWNLOADS=never

# Clone the repository (assuming it's passed as an argument or already present)
# If the repo is already mounted/copied, skip this step
if [ ! -d ".git" ]; then
    echo "Repository not found. Assuming it will be mounted or copied."
fi

# Verify Python 3.12 is available
echo "Verifying Python 3.12..."
python --version

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