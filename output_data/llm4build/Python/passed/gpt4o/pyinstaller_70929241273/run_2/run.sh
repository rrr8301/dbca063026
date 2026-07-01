#!/bin/bash

# Update pip and install hatchling
python3.11 -m pip install --upgrade pip hatchling

# Compile bootloader
cd bootloader && python3.11 waf --tests all

# Download dependencies
python3.11 -m pip download --dest=dist .[completion] && rm -f dist/pyinstaller-*.whl

# Build wheels
sh release/build-wheels

# Install PyInstaller
python3.11 -m pip install --no-index --find-links=dist pyinstaller[completion]

# Check pyinstaller --help
python3.11 -m PyInstaller -h

# Run tests
pytest -n 5 --maxfail 3 --durations 10 tests/unit tests/functional

# Install hooksample
python3.11 -m pip install "https://github.com/pyinstaller/hooksample/archive/v4.0rc1.zip"

# Run hooksample tests
cd ~
python3.11 -m PyInstaller.utils.run_tests --include_only=pyi_hooksample.