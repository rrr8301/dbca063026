#!/bin/bash

# Activate environment
export PYTHONWARNDEFAULTENCODING=true
export FORCE_COLOR=1
export PYINSTALLER_STRICT_UNPACK_MODE=1
export PYINSTALLER_STRICT_COLLECT_MODE=1
export PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1
export PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1

# Update pip and install dependencies
python -m pip install --upgrade pip hatchling
python -m pip install --progress-bar=off --upgrade --requirement tests/requirements-base.txt
python -m pip install --progress-bar=off --upgrade --requirement tests/requirements-libraries.txt

# Run tests
pytest -n 5 --maxfail 3 --durations 10 tests/unit tests/functional

# Additional commands from the YAML
cd bootloader
CC="gcc -std=gnu90" python waf --tests all
CC="gcc -std=c99 -pedantic" python waf --tests all
python waf --static-zlib --tests all
cd ..

# Download AppImage tool
wget https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage -O $HOME/appimagetool-x86_64.AppImage
chmod a+x $HOME/appimagetool-x86_64.AppImage

# Compile bootloader
cd bootloader && python waf --tests all

# Download dependencies
python -m pip download --dest=dist .[completion] && rm -f dist/pyinstaller-*.whl

# Build wheels
sh release/build-wheels

# Check pyinstaller --help
python -m PyInstaller -h

# Start display server
Xvfb :99 &
export DISPLAY=:99

# Run hooksample tests
cd ~
python -m PyInstaller.utils.run_tests --include_only=pyi_hooksample.