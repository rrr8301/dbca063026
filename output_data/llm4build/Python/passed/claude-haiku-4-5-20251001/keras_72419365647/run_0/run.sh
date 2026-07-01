#!/bin/bash
set -e

# Install Python dependencies
pip install -r requirements.txt
pip install --no-deps tf_keras

# Run integration tests
echo "Running integration tests..."
python integration_tests/import_test.py
python integration_tests/numerical_test.py
python integration_tests/tf_distribute_training_test.py
python integration_tests/tf_custom_fit_test.py

# Run pytest with coverage
echo "Running pytest with coverage..."
pytest keras --ignore keras/src/applications --cov=keras --cov-config=pyproject.toml $PYTEST_ARGS
coverage xml --omit='keras/src/applications/*,keras/api' -o core-coverage.xml

echo "All tests completed successfully!"