#!/bin/bash

# Activate environment variables
export PYTHON=3.11
export KERAS_HOME=.github/workflows/config/jax

# Run integration tests
python integration_tests/import_test.py
python integration_tests/numerical_test.py

# Run JAX-specific integration tests
python integration_tests/jax_custom_fit_test.py

# Run pytest with coverage
pytest keras --ignore keras/src/applications --cov=keras --cov-config=pyproject.toml
coverage xml --omit='keras/src/applications/*,keras/api' -o core-coverage.xml