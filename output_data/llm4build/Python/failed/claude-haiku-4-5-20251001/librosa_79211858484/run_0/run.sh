#!/bin/bash
set -e

# Activate conda environment
source /opt/miniforge/etc/profile.d/conda.sh
conda activate test

# Display conda info
echo "=== Conda Info ==="
conda info -a
conda list

# Update conda environment from environment file
echo "=== Updating conda environment ==="
mamba env update -n test -f .github/environment-ci.yml

# Display scipy config
echo "=== SciPy Config ==="
python -c "import scipy; scipy.show_config()"

# Install librosa with test extras
echo "=== Installing librosa ==="
python -m pip install --upgrade-strategy only-if-needed -e .[tests]

# Run pytest
echo "=== Running pytest ==="
pytest --mpl-results-path=mpl_image_results/