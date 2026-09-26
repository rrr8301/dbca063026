#!/bin/bash
set -e

# Activate conda base environment
source /opt/miniconda/etc/profile.d/conda.sh
conda activate base

# Set environment variables for test execution
export PYTEST_MARKER='integration'
export PYTEST_SPLITS='3'
export CONDA_TEST_SOLVERS='libmamba'

# Initialize conda for all shells
python -m conda init --all

# Configure conda with the provided condarc file
if [ -f .github/condarc-defaults ]; then
    cp .github/condarc-defaults ~/.condarc
fi

# Accept Anaconda ToS for non-interactive usage
echo "Accepting Anaconda Terms of Service..."
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true

# Install conda dependencies from requirement files
echo "Installing conda dependencies..."
conda install \
    --yes \
    --file tests/requirements.txt \
    --file tests/requirements-Linux.txt \
    --file tests/requirements-ci.txt \
    --file tests/requirements-s3.txt \
    python=3.11

# Display conda information for debugging
echo "=== Conda Info ==="
python -m conda info --verbose

echo "=== Conda Config ==="
conda config --show-sources

echo "=== Conda List ==="
conda list --show-channel-urls

# Create durations directory if it doesn't exist
mkdir -p durations

# Run tests with pytest
echo "=== Running Tests ==="
python -m pytest \
    --cov=conda \
    --durations-path=durations/Linux.json \
    --group=1 \
    --splits=3 \
    -m "integration"

echo "=== Tests Complete ==="