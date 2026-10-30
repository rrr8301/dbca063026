#!/usr/bin/env bash
set -e

cd /app

echo "=== Building proxygen ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. proxygen --project-install-prefix proxygen:/usr/local

echo "=== Testing proxygen ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. proxygen --project-install-prefix proxygen:/usr/local

echo "FINAL_STATUS = SUCCESS"
