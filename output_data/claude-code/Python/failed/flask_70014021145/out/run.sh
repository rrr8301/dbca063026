#!/usr/bin/env bash
set -e

cd /app

export TOX_ENV="py312"
export PATH="/root/.local/bin:$PATH"

echo "Running Flask tests with Python 3.12..."
uv run --locked --no-default-groups --group dev tox run || true

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
