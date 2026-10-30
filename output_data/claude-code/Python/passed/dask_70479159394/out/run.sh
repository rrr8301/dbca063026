#!/usr/bin/env bash

set -e

source /opt/conda/etc/profile.d/conda.sh
conda activate test-environment

cd /app

echo "=== Running import tests ==="
python -m pytest dask/tests/test_imports.py

echo "=== Running full test suite ==="
CMD="python -m pytest dask --runslow"

if [[ $COVERAGE == 'true' ]]; then
    CMD="$CMD --cov --cov-report=xml --junit-xml=pytest.xml"
fi

if [[ $ARRAYEXPR == 'true' ]]; then
    CMD="$CMD --runarrayexpr"
fi

if [[ $PARALLEL == 'true' ]]; then
    CMD="$CMD -n4"
fi

env | grep DASK || true
echo "$CMD"
$CMD

echo "FINAL_STATUS = SUCCESS"
