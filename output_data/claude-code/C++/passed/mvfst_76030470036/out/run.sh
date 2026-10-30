#!/usr/bin/env bash
set -e

cd /app

echo "===== Building mvfst ====="
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --build-type RelWithDebInfo --src-dir=. mvfst --project-install-prefix mvfst:/usr/local

echo "===== Copying artifacts ====="
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. mvfst _artifacts/linux --project-install-prefix mvfst:/usr/local --final-install-prefix /usr/local || true

echo "===== Testing mvfst ====="
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --build-type RelWithDebInfo --src-dir=. mvfst --project-install-prefix mvfst:/usr/local

echo ""
echo "FINAL_STATUS = SUCCESS"
