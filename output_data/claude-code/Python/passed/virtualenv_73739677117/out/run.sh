#!/usr/bin/env bash
set -e

export TOXENV="3.12"
export PYTEST_ADDOPTS="-vv --durations=20"
export CI_RUN="yes"
export DIFF_AGAINST="HEAD"
export PIP_DISABLE_PIP_VERSION_CHECK="1"

echo "Setting up test suite with tox..."
tox run -vvvv --notest --skip-missing-interpreters false

echo "Running test suite..."
tox run --skip-pkg-install

FINAL_STATUS = SUCCESS
