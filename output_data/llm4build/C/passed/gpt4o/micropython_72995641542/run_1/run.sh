#!/bin/bash

# Activate Python environment
python3.11 -m venv venv
source venv/bin/activate

# Install project dependencies if any (placeholder)
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi

# Run the setup, build, and test scripts
tools/ci.sh unix_coverage_setup
tools/ci.sh unix_coverage_build
tools/ci.sh unix_coverage_run_tests
tools/ci.sh unix_coverage_run_mpy_merge_tests
tools/ci.sh native_mpy_modules_build
tools/ci.sh unix_coverage_run_native_mpy_tests

# Run gcov coverage analysis
(cd ports/unix && gcov -o build-coverage/py ../../py/*.c || true)
(cd ports/unix && gcov -o build-coverage/extmod ../../extmod/*.c || true)

# Print test failures
tests/run-tests.py --print-failures || true

# Ensure all tests are executed even if some fail
exit 0