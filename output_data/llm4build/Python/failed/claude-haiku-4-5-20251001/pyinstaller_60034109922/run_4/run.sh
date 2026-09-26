#!/bin/bash

set -e

# Set Python 3.11 as default
export PYTHON_VERSION=3.11
export PATH="/usr/local/bin:/usr/bin:$PATH"

# Set up display for GUI tests
export DISPLAY=:99
Xvfb :99 &
XVFB_PID=$!
sleep 2

# Set temporary directory for pytest
export PYTEST_DEBUG_TEMPROOT=/tmp/pytest-temp
mkdir -p "$PYTEST_DEBUG_TEMPROOT"

# Navigate to workspace
cd /workspace

echo "=== Checking bootloader code conformance to gnu90 C standard ==="
cd bootloader
CC="gcc -std=gnu90" python3.11 waf --tests all
cd ..

echo "=== Checking bootloader code conformance to c99 ISO C standard (pedantic mode) ==="
cd bootloader
CC="gcc -std=c99 -pedantic" python3.11 waf --tests all
cd ..

echo "=== Checking if bootloader is buildable with --static-zlib option ==="
cd bootloader
python3.11 waf --static-zlib --tests all
cd ..

echo "=== Compiling bootloader ==="
cd bootloader
python3.11 waf --tests all
cd ..

echo "=== Downloading dependencies ==="
python3.11 -m pip download --dest=dist .[completion] && rm -f dist/pyinstaller-*.whl

echo "=== Building wheels ==="
sh release/build-wheels

echo "=== Installing PyInstaller ==="
python3.11 -m pip install --no-index --find-links=dist pyinstaller[completion]

echo "=== Checking pyinstaller --help ==="
python3.11 -m PyInstaller -h

echo "=== Installing test dependencies (base tools) ==="
python3.11 -m pip install --progress-bar=off --upgrade --requirement tests/requirements-base.txt

echo "=== Installing test dependencies (tools and libraries) ==="
python3.11 -m pip install --progress-bar=off --upgrade --requirement tests/requirements-libraries.txt

echo "=== Working around potentially broken setuptools upgrade ==="
python3.11 << 'EOF'
import sys
import pathlib
import shutil
import importlib.util

try:
  spec = importlib.util.find_spec('setuptools._vendor.importlib_resources')
except ImportError:
  spec = None
if spec is None:
  print("Did not find setuptools-vendored copy of importlib_resources.")
  sys.exit(0)
elif spec.loader is not None:
  print("Found a valid setuptools-vendored copy of importlib_resources.")
  sys.exit(0)

print("Found a defunct setuptools-vendored copy of importlib_resources!")

def list_directory(path, pad=""):
  for child in path.iterdir():
    if child.is_dir():
      print(f"{pad} + {child.name}")
      list_directory(child, pad + " ")
    else:
      print(f"{pad} - {child.name} ({child.stat().st_size} bytes)")

for path in spec.submodule_search_locations:
  print(f"Listing contents of {path}")
  list_directory(pathlib.Path(path))

for path in spec.submodule_search_locations:
  print(f"Removing {path}...")
  shutil.rmtree(path)
EOF

echo "=== Running tests ==="
pytest \
    -n 5 --maxfail 3 --durations 10 tests/unit tests/functional || TEST_FAILED=1

echo "=== Installing hooksample ==="
python3.11 -m pip install "https://github.com/pyinstaller/hooksample/archive/v4.0rc1.zip"

echo "=== Injecting bogus hooks ==="
python3.11 << 'EOF'
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

echo "=== Running hooksample tests ==="
cd ~
python3.11 -m PyInstaller.utils.run_tests --include_only=pyi_hooksample. || HOOKSAMPLE_FAILED=1

# Clean up Xvfb
kill $XVFB_PID 2>/dev/null || true

# Exit with failure if tests failed
if [ "$TEST_FAILED" = "1" ] || [ "$HOOKSAMPLE_FAILED" = "1" ]; then
    exit 1
fi

exit 0