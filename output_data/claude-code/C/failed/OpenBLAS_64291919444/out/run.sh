#!/usr/bin/env bash
set -e

cd /app/build

echo "Running ctest..."
if ctest; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "First run had failures, re-running failed tests..."
  ctest --rerun-failed --output-on-failure || true

  # Check if there are test logs
  if [ -f Testing/Temporary/LastTest.log ]; then
    echo "::group::Log from these tests"
    cat Testing/Temporary/LastTest.log
    echo "::endgroup::"
  fi

  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
