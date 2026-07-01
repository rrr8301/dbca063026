#!/usr/bin/env bash
set -e

# Set environment variables as specified in the CI workflow
export ARCH_ON_CI="normal"
export IS_CRON="false"
export PY_COLORS="1"
export NUMPY_WARN_IF_NO_MEM_POLICY=1
export ASTROPY_ALWAYS_TEST_FITSIO=true

# Run the tox environment
cd /app
python -m tox -e py312-test-alldeps-fitsio -v --develop -- -n=4 --run-slow

# If we got here, tests ran successfully
echo ""
echo "FINAL_STATUS = SUCCESS"
