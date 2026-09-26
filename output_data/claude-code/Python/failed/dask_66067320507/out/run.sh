#!/usr/bin/env bash

set -e

# Initialize conda
source /opt/conda/etc/profile.d/conda.sh

conda activate test-environment

# Configure pytest-timeout to use signal instead of thread (no SIGALRM on Windows, but we're on Linux)
sed -i.bak 's/timeout_method = "thread"/timeout_method = "signal"/' /app/pyproject.toml

# Export conda environment
echo -e "\n-- Conda Environment --"
conda env export | grep -E -v '^prefix:.*$' > env.yaml
cat env.yaml

echo -e "\n-- Starting Import Tests --"
python -m pytest /app/dask/tests/test_imports.py

echo -e "\n-- Starting Full Test Suite --"
export PARALLEL=true
export COVERAGE=true
export ARRAYEXPR=false
export HDF5_USE_FILE_LOCKING=FALSE

CMD="python -m pytest /app/dask --runslow"
CMD="$CMD --cov --cov-report=xml --junit-xml=pytest.xml"
CMD="$CMD -n4"

echo "$CMD"
$CMD

echo -e "\n-- Tests completed successfully --"
echo "FINAL_STATUS = SUCCESS"
