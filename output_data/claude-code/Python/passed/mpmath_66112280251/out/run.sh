#!/usr/bin/env bash
set -e

cd /app
pytest

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS=$FINAL_STATUS"
