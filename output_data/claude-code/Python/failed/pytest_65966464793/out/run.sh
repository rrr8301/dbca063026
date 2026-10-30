#!/usr/bin/env bash
set -e

cd /app

export PYTEST_ADDOPTS="--color=yes"
export CI=true
export _PYTEST_TOX_POSARGS_JUNIT="--junitxml=junit.xml"

echo "Running pytest via tox with coverage..."
tox run -e py311-coverage

FINAL_STATUS=$?
if [ $FINAL_STATUS -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
fi
exit $FINAL_STATUS
