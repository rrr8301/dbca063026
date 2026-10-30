#!/usr/bin/env bash
set -e

cd /app

# Run the specific tox environment for Python 3.12 with minimal deps and coverage
python3.12 -m tox -e py312-test-cov --verbose

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi
