#!/usr/bin/env bash

set -e

cd /app

# Query paths
python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. wangle > /tmp/paths.txt

# Build wangle
echo "Building wangle..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. wangle --project-install-prefix wangle:/usr/local

# Copy artifacts
echo "Copying artifacts..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. wangle _artifacts/linux --project-install-prefix wangle:/usr/local --final-install-prefix /usr/local

# Test wangle
echo "Testing wangle..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. wangle --project-install-prefix wangle:/usr/local

echo "FINAL_STATUS = SUCCESS"
