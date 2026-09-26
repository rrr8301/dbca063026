#!/usr/bin/env bash
set -e

cd /app

python3.12 -m pip install --upgrade pip

pip install -r requirements-dev.txt

pytest -n auto

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS=$FINAL_STATUS"
