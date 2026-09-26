#!/bin/bash

# Activate environment variables
export NO_AT_BRIDGE=1
export OPENBLAS_NUM_THREADS=1
export PYTHONFAULTHANDLER=1

# Install Matplotlib
ccache -s
git describe
export CPPFLAGS='--coverage -fprofile-abs-path'
python3.12 -m pip install --no-deps --no-build-isolation --verbose \
  --config-settings=setup-args="-DrcParams-backend=Agg" \
  --editable .
unset CPPFLAGS

# Run tests
pytest -rfEsXR -n auto \
  --maxfail=50 --timeout=300 --durations=25 \
  --cov-report=xml --cov=lib --log-level=DEBUG --color=yes || true