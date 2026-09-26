#!/usr/bin/env bash
set -e

cd /app

echo "=== Update system package info ==="
apt-get update

echo "=== Install system deps ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive folly
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

echo "=== Query paths ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. folly > /tmp/paths.txt
cat /tmp/paths.txt

echo "=== Build folly ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. folly --project-install-prefix folly:/usr/local

echo "=== Test folly ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. folly --project-install-prefix folly:/usr/local

echo "FINAL_STATUS = SUCCESS"
