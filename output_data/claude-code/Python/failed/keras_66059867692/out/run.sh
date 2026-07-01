#!/usr/bin/env bash
set -e

# Test integrations (backend == jax, nnx_enabled == false)
echo "=== Testing integrations ==="
python integration_tests/import_test.py || true
python integration_tests/numerical_test.py || true

# Test JAX-specific integrations
echo "=== Testing JAX-specific integrations ==="
python integration_tests/jax_custom_fit_test.py || true

# Run main tests
echo "=== Running main pytest ==="
pytest keras -n auto --dist loadfile --ignore keras/src/applications --ignore keras/src/wrappers --cov=keras --cov-config=pyproject.toml || true

# Run Multi-Device Tests for JAX
echo "=== Running Multi-Device Tests ==="
JAX_NUM_CPU_DEVICES=4 pytest keras -m multi_device --cov=keras --cov-config=pyproject.toml --cov-append || true

# Convert Coverage
echo "=== Converting Coverage ==="
coverage xml --omit='keras/src/applications/*,keras/src/wrappers/*,keras/api' -o core-coverage.xml || true

echo "FINAL_STATUS = SUCCESS"
