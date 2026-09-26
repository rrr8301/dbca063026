#!/bin/bash
set -e

# Clone the repository (if not already present)
if [ ! -d "/workspace/.git" ]; then
    cd /tmp
    git clone https://github.com/pyinstaller/pyinstaller.git /tmp/pyinstaller-repo
    cd /tmp/pyinstaller-repo
    # Move contents to /workspace
    shopt -s dotglob
    mv * /workspace/
    cd /workspace
fi

# Set environment variables from the workflow
export FORCE_COLOR=1
export PYINSTALLER_STRICT_UNPACK_MODE=1
export PYINSTALLER_STRICT_COLLECT_MODE=1
export PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1
export PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1
export PYTHONWARNDEFAULTENCODING=true
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export PYTHONIOENCODING=utf-8

# Update pip and install hatchling
python -m pip install --upgrade pip hatchling

# Compile bootloader
cd /workspace/bootloader
python waf --tests all
cd /workspace

# Download dependencies
python -m pip download --dest=dist .[completion] && rm -f dist/pyinstaller-*.whl

# Build wheels
sh release/build-wheels

# Install PyInstaller
python -m pip install --no-index --find-links=dist pyinstaller[completion]

# Check pyinstaller --help
python -m PyInstaller -h

# Install test dependencies (base tools)
python -m pip install --progress-bar=off --upgrade --requirement tests/requirements-base.txt

# Install test dependencies (tools and libraries)
python -m pip install --progress-bar=off --upgrade --requirement tests/requirements-libraries.txt

# Work around potentially broken setuptools upgrade
python << 'EOF'
import sys
import pathlib
import shutil
import importlib.util

PACKAGES = [
  'setuptools._vendor.importlib_resources',
  'pkg_resources',
]

def fix_package(package_name):
  try:
    spec = importlib.util.find_spec(package_name)
  except ImportError:
    spec = None
  if spec is None:
    print(f"Did not find {package_name}.")
    return
  elif spec.loader is not None:
    print(f"Found a valid copy of {package_name}.")
    return

  print(f"Found a defunct copy of {package_name}!")

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

for package in PACKAGES:
  fix_package(package)
EOF

# Set pytest temp directory
export PYTEST_DEBUG_TEMPROOT=/tmp/pytest-temp
mkdir -p $PYTEST_DEBUG_TEMPROOT

# Run tests (continue even if tests fail)
TEST_FAILED=0
pytest -n 5 --maxfail 3 --durations 10 tests/unit tests/functional || TEST_FAILED=1

# Install hooksample
python -m pip install "https://github.com/pyinstaller/hooksample/archive/v4.0rc1.zip"

# Inject bogus hooks
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

# Run hooksample tests (continue even if tests fail)
HOOKSAMPLE_FAILED=0
cd ~
python -m PyInstaller.utils.run_tests --include_only=pyi_hooksample. || HOOKSAMPLE_FAILED=1

# Exit with failure if any test suite failed
if [ "$TEST_FAILED" = "1" ] || [ "$HOOKSAMPLE_FAILED" = "1" ]; then
    exit 1
fi

exit 0