#!/usr/bin/env bash
set -e

cd /app

export PYTEST_ADDOPTS="--color=yes"
export CI=true
export _PYTEST_TOX_POSARGS_JUNIT="--junitxml=junit.xml"

echo "Starting tox run for py311-coverage..."
tox run -e py311-coverage --installpkg `find dist/*.tar.gz` 2>&1

echo "FINAL_STATUS = SUCCESS"
