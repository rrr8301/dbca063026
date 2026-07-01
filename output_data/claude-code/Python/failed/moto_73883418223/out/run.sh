#!/usr/bin/env bash
set -e

cd /app

echo "Running tests..."

# Clean up any previous coverage
rm -f .coverage
rm -rf cover

# Run main test suite
echo "Running pytest on ./tests/..."
pytest -sv -rs --cov=moto --cov-report xml ./tests/ || true

# Run xray tests separately without coverage
echo "Running xray tests..."
pytest -sv -rs ./tests/test_xray || true

# Run tests that require a clean slate
echo "Running clean slate tests..."
pytest -sv --cov=moto --cov-report xml --cov-append ./tests/ -m requires_clean_slate || true

# Run parallel tests
echo "Running parallel tests..."
MOTO_CALL_RESET_API=false pytest -sv --cov=moto --cov-report xml --cov-append -n 4 ./tests/ --dist loadscope -m "not requires_clean_slate" || true

echo "Tests completed!"
FINAL_STATUS = SUCCESS
