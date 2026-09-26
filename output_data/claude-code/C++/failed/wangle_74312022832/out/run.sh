#!/usr/bin/env bash

set -e

cd /app

echo "=== Update system package info ==="
apt-get update

echo "=== Install system deps ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive wangle
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

echo "=== Query paths ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. wangle > /tmp/paths.txt
cat /tmp/paths.txt

echo "=== Build wangle ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. wangle --project-install-prefix wangle:/usr/local

echo "=== Copy artifacts ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. wangle _artifacts/linux --project-install-prefix wangle:/usr/local --final-install-prefix /usr/local

echo "=== Test wangle ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. wangle --project-install-prefix wangle:/usr/local

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
