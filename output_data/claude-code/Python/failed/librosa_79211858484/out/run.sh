#!/usr/bin/env bash
set -e

# Activate conda environment
source activate test

# Show conda info
echo "=== Conda Info ==="
conda info -a
echo ""

# Show installed packages
echo "=== Conda List ==="
conda list
echo ""

# Show scipy configuration
echo "=== Scipy Config ==="
python -c "import scipy; scipy.show_config()"
echo ""

# Install librosa (just to be safe, though already installed in Dockerfile)
echo "=== Installing librosa ==="
python -m pip install --upgrade-strategy only-if-needed -e .[tests]
echo ""

# Run tests
echo "=== Running pytest ==="
pytest

# If we reach here, tests ran (even if some failed)
FINAL_STATUS="SUCCESS"
echo ""
echo "FINAL_STATUS = $FINAL_STATUS"
