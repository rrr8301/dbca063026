#!/bin/bash

# Activate the conda environment
source /opt/conda/etc/profile.d/conda.sh
conda activate test

# Run tests
pytest --mpl-results-path=mpl_image_results/