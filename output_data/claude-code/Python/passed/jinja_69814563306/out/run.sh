#!/usr/bin/env bash

set -e

cd /app

# Run the exact test command from the workflow
uv run --locked tox run -e py313

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
