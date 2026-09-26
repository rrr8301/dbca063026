#!/usr/bin/env bash
set -e

cd /app

echo "=== Update system package info ==="
apt-get update

echo "=== Install system deps ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive mvfst
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

echo "=== Build mvfst ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. mvfst --project-install-prefix mvfst:/usr/local

echo "=== Copy artifacts ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. mvfst _artifacts/linux --project-install-prefix mvfst:/usr/local --final-install-prefix /usr/local

echo "=== Test mvfst ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. mvfst --project-install-prefix mvfst:/usr/local

echo "FINAL_STATUS = SUCCESS"
