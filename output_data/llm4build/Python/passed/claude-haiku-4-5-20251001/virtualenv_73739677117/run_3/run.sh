#!/bin/bash
set -e

# Set environment variables
export TOXENV=py312
export PYTEST_ADDOPTS="-vv --durations=20"
export CI_RUN="yes"
export DIFF_AGAINST=HEAD
export PIP_DISABLE_PIP_VERSION_CHECK="1"
export PATH="/root/.local/bin:${PATH}"

# Fetch upstream tags for versioning
echo "📥 Fetching upstream tags..."
git fetch --force --tags https://github.com/pypa/virtualenv.git

# Install tox with uv using Python 3.12
echo "📦 Installing tox with uv..."
uv tool install --no-managed-python --python 3.12 "tox>=4.45" --with tox-uv --with .

# Setup test suite (prepare environment without running tests)
echo "🏗️ Setting up test suite..."
tox run -e py312 -vvvv --notest --skip-missing-interpreters false

# Run test suite
echo "🏃 Running test suite..."
tox run -e py312 --skip-pkg-install

echo "✅ Test suite completed successfully!"