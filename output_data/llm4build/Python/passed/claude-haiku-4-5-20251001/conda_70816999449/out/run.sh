#!/bin/bash
set -e

# Activate conda base environment
source /home/conda_user/miniconda3/etc/profile.d/conda.sh
conda activate base

# Set environment variables
export CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true
export PYTEST_MARKER=integration
export PYTEST_SPLITS=3
export CONDA_TEST_SOLVERS=libmamba

# Configure conda with condarc file
if [ -f .github/condarc-defaults ]; then
    conda config --file .github/condarc-defaults
fi

# Accept Conda TOS for default channels (ensure acceptance)
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
    python=3.12

# Display conda info for debugging
echo "=== Conda Info ==="
python -m conda info --verbose

echo "=== Conda Config Sources ==="
conda config --show-sources

echo "=== Conda List ==="
conda list --show-channel-urls

# Run tests with pytest
echo "=== Running Integration Tests ==="
python -m pytest \
    --cov=conda \
    --durations-path=durations/Linux.json \
    --group=3 \
    --splits=3 \
    -m "integration"

echo "=== Tests Completed ==="