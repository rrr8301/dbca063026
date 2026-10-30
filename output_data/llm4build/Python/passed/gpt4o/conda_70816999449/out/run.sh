#!/bin/bash

# Activate conda environment
source /opt/conda/bin/activate base

# Initialize shells
python -m conda init --all

# Run tests
python -m pytest \
    --cov=conda \
    --durations-path=durations/ubuntu-latest.json \
    --group=3 \
    --splits=3 \
    -m "integration"