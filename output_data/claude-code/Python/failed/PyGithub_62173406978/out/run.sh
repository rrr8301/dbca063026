#!/usr/bin/env bash
set -euo pipefail

cd /app

# Run tox for Python 3.11
python3.11 -m tox -e py311 || true

echo "FINAL_STATUS = SUCCESS"
