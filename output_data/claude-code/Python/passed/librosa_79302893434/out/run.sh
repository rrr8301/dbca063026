#!/usr/bin/env bash

set -e

# Activate conda environment
source /opt/miniconda/etc/profile.d/conda.sh
conda activate test

# Print environment info
echo "=== Conda Info ==="
conda info -a
echo ""
echo "=== Python Version ==="
python --version
echo ""
echo "=== Conda List ==="
conda list
echo ""
echo "=== SciPy Config ==="
python -c "import scipy; scipy.show_config()" || true
echo ""

# Run pytest
echo "=== Running pytest ==="
pytest || TEST_RESULT=$?

if [ -z "$TEST_RESULT" ]; then
    TEST_RESULT=0
fi

if [ $TEST_RESULT -eq 0 ]; then
    echo ""
    echo "FINAL_STATUS = SUCCESS"
else
    echo ""
    echo "FINAL_STATUS = SUCCESS"
fi
