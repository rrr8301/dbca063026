#!/bin/bash

# Activate Conda environment
source /opt/conda/etc/profile.d/conda.sh
conda activate test-environment

# Reconfigure pytest-timeout
sed -i.bak 's/timeout_method = "thread"/timeout_method = "signal"/' pyproject.toml

# Install project dependencies
source continuous_integration/scripts/install.sh

# Run import tests
pytest dask/tests/test_imports.py || true

# Run tests
source continuous_integration/scripts/run_tests.sh || true