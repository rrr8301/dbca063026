#!/bin/bash

# Activate conda environment
source /opt/conda/bin/activate test-env

# Run tests
python -m pytest \
    --cov=conda \
    --durations-path=durations/ubuntu.json \
    --group=1 \
    --splits=3 \
    -m "integration"