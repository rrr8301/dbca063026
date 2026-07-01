#!/bin/bash

# Activate the conda environment
source /opt/conda/bin/activate test-environment

# Reconfigure pytest-timeout
sed -i.bak 's/timeout_method = "thread"/timeout_method = "signal"/' pyproject.toml

# Install project dependencies
source continuous_integration/scripts/install.sh

# Run import tests
pytest dask/tests/test_imports.py || true

# Run tests
PARALLEL="true" COVERAGE="true" ARRAYEXPR="false" HDF5_USE_FILE_LOCKING="FALSE" \
source continuous_integration/scripts/run_tests.sh || true