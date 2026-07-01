#!/bin/bash
set -e

cd /workspace

# Replace Pipfile with max version (pipfile-version=max)
rm -f Pipfile
mv tools/packages/pipfiles/Pipfile3.11.max Pipfile

# Install pipenv dependencies
pipenv install --dev --python=3.11

# Setup Node.js (already installed in Dockerfile, just ensure npm is available)
node --version
npm --version

# Hash frontend source code
pipenv run python tools/frontend/hash_source.py
HASH=$(cat hash.txt)
rm -f hash.txt

# Frontend Bundle Build
pipenv run python tools/frontend/bundle_build.py

# Install Playwright chromium
pipenv run playwright install chromium --with-deps

# Run pytest with excluded markers
pipenv run pytest -m "not orchestrator_dispatcher and not standalone and not teste2e" tests