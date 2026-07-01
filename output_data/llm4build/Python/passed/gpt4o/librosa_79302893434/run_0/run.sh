#!/bin/bash

# Activate the conda environment
source /opt/conda/bin/activate test

# Run tests
pytest --mpl-results-path=mpl_image_results/