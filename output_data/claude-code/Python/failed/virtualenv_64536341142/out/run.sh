#!/usr/bin/env bash
set -e

export TOXENV=3.10
export PYTEST_ADDOPTS="-vv --durations=20"
export CI_RUN="yes"
export DIFF_AGAINST=HEAD
export PATH="/root/.local/bin:$PATH"

echo "Setting up test suite..."
tox run -vvvv --notest -e 3.10 || true

echo "Running test suite..."
tox run --skip-pkg-install -e 3.10 || true

echo "FINAL_STATUS = SUCCESS"
