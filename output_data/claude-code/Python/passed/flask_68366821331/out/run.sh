#!/usr/bin/env bash
set -e

cd /app
export TOX_ENV=py313

uv run --locked tox run

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
