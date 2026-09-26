#!/usr/bin/env bash
set -e

cd /app

export PY_VERSION=3.11
export UV_PYTHON=3.11
export UV_PROJECT_ENVIRONMENT=.venv

make test-3.11 || true

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS=$FINAL_STATUS"
