#!/usr/bin/env bash
set -e

cd /app

# Install tox environment
python3.11 -m tox run -e py --notest

# Run tests
python3.11 -m tox run -e py --skip-pkg-install -- -n 4

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS=$FINAL_STATUS"
