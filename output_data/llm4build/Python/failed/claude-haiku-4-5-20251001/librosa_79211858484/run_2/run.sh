#!/bin/bash
set -e

# Source conda initialization
source /opt/miniforge/etc/profile.d/conda.sh

# Activate conda environment
conda activate test

# Display conda info
echo "=== Conda Info ==="
conda info -a
conda list

# Update conda environment from environment file
echo "=== Updating conda environment ==="
if [ -f .github/environment-ci.yml ]; then
    mamba env update -n test -f .github/environment-ci.yml
else
    echo "Warning: .github/environment-ci.yml not found, skipping environment update"
fi

# Display scipy config
echo "=== SciPy Config ==="
python -c "import scipy; scipy.show_config()" || echo "SciPy not yet installed"

# Install librosa with test extras
echo "=== Installing librosa ==="
python -m pip install --upgrade-strategy only-if-needed -e .[tests]

# Run pytest
echo "=== Running pytest ==="
pytest --mpl-results-path=mpl_image_results/