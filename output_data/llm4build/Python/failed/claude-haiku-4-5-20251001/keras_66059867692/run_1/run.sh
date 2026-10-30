#!/bin/bash
set -e

python integration_tests/import_test.py
python integration_tests/numerical_test.py
python integration_tests/jax_custom_fit_test.py
pytest keras --ignore keras/src/applications --cov=keras --cov-config=pyproject.toml
coverage xml --omit='keras/src/applications/*,keras/api' -o core-coverage.xml