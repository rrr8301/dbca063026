#!/bin/bash

# Activate environment variables
export KERAS_HOME=.github/workflows/config/tensorflow

# Run integration tests
python integration_tests/import_test.py
python integration_tests/numerical_test.py

# Run TF-specific integration tests
python integration_tests/tf_distribute_training_test.py
python integration_tests/tf_custom_fit_test.py

# Run tests with pytest
pytest keras --ignore keras/src/applications --cov=keras --cov-config=pyproject.toml $PYTEST_ARGS
coverage xml --omit='keras/src/applications/*,keras/api' -o core-coverage.xml