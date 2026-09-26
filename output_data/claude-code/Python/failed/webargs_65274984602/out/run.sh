#!/usr/bin/env bash
set -e

cd /app
python3.10 -m tox -epy310-marshmallow

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
