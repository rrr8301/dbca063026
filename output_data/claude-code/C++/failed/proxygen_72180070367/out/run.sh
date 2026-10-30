#!/usr/bin/env bash
set -x

cd /app

echo "=== Update system package info ==="
apt-get update

echo "=== Install system dependencies ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive proxygen
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

echo "=== Build proxygen ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --build-type RelWithDebInfo --src-dir=. proxygen --project-install-prefix proxygen:/usr/local

echo "=== Test proxygen ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --build-type RelWithDebInfo --src-dir=. proxygen --project-install-prefix proxygen:/usr/local

TEST_EXIT=$?

if [ $TEST_EXIT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi

exit 0
