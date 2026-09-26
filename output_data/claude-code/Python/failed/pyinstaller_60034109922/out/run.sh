#!/usr/bin/env bash
set -e

cd /app

# Start display server
Xvfb :99 -screen 0 1024x768x24 &
export DISPLAY=:99

# Set temp directory
export PYTEST_DEBUG_TEMPROOT=/tmp

# Run main tests
echo "=== Running main tests ==="
pytest -n 5 --maxfail 3 --durations 10 tests/unit tests/functional || true

# Inject bogus hooks
echo "=== Injecting bogus hooks ==="
python << 'EOF'
import os
from _pyinstaller_hooks_contrib import (
    stdhooks,
    pre_safe_import_module,
    pre_find_module_path,
)
with open(os.path.join(stdhooks.__path__[0], "hook-pyi_hooksample.py"), "w", encoding="utf-8") as f:
    f.write('raise Exception("Wrong hook! Use the pyi_hooksample copy instead!")\n')
with open(os.path.join(pre_safe_import_module.__path__[0], "hook-pyi_hooksample.py"), "w", encoding="utf-8") as f:
    f.write('raise Exception("Wrong hook! Use the pyi_hooksample copy instead!")\n')
with open(os.path.join(pre_find_module_path.__path__[0], "hook-pyi_hooksample.py"), "w", encoding="utf-8") as f:
    f.write('raise Exception("Wrong hook! Use the pyi_hooksample copy instead!")\n')
EOF

# Run hooksample tests
echo "=== Running hooksample tests ==="
cd ~
python -m PyInstaller.utils.run_tests --include_only=pyi_hooksample. || true

# Tests have run
echo "FINAL_STATUS = SUCCESS"
