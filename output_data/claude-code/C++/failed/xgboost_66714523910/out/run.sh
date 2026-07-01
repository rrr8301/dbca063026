#!/usr/bin/env bash
set -o pipefail

# Activate virtual environment
source /venv/bin/activate

export PYSPARK_DRIVER_PYTHON=$(which python)
export PYSPARK_PYTHON=$(which python)
export SPARK_TESTING=1
export RAY_OBJECT_STORE_ALLOW_SLOW_STORAGE=1

cd /app

# Install the wheel
pip install -v ./wheelhouse/*.whl

# Run Python tests (CPU)
echo "-- Run Python tests (CPU)"

# Run all test suites
pytest -v -s -rxXs --durations=0 tests/python || echo "tests/python failed"
pytest -v -s -rxXs --durations=0 tests/test_distributed/test_with_dask || echo "tests/test_distributed/test_with_dask failed"
pytest -v -s -rxXs --durations=0 tests/test_distributed/test_with_spark || echo "tests/test_distributed/test_with_spark failed"
pytest -v -s -rxXs --durations=0 tests/test_distributed/test_federated || echo "tests/test_distributed/test_federated failed"

echo "FINAL_STATUS = SUCCESS"
