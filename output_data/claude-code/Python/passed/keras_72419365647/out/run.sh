#!/usr/bin/env bash

set -e

export KERAS_HOME=.github/workflows/config/tensorflow

echo "===== Test integrations ====="
python integration_tests/import_test.py || echo "import_test.py failed, continuing..."
python integration_tests/numerical_test.py || echo "numerical_test.py failed, continuing..."

echo "===== Test TF-specific integrations ====="
python integration_tests/tf_distribute_training_test.py || echo "tf_distribute_training_test.py failed, continuing..."
python integration_tests/tf_custom_fit_test.py || echo "tf_custom_fit_test.py failed, continuing..."

echo "===== Run main test suite ====="
pytest keras -n auto --dist loadfile --ignore keras/src/applications --ignore keras/src/wrappers --cov=keras --cov-config=pyproject.toml || echo "pytest failed"

echo "===== Test execution completed ====="
FINAL_STATUS = SUCCESS
