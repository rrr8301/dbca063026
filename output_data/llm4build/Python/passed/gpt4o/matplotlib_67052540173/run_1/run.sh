#!/bin/bash

# Activate Python environment
python3.12 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install --upgrade pip setuptools wheel
pip install --upgrade \
    'contourpy>=1.0.1' cycler fonttools kiwisolver importlib_resources \
    packaging pillow 'pyparsing!=3.1.0' python-dateutil setuptools-scm \
    'meson-python>=0.13.1' 'pybind11>=2.13.2' \
    -r requirements/testing/all.txt

# Install Matplotlib
ccache -s
git describe
export CPPFLAGS='--coverage -fprofile-abs-path'
pip install --no-deps --no-build-isolation --verbose \
    --config-settings=setup-args="-DrcParams-backend=Agg" \
    --editable .

# Run tests
pytest -rfEsXR -n auto \
    --maxfail=50 --timeout=300 --durations=25 \
    --cov-report=xml --cov=lib --log-level=DEBUG --color=yes