#!/usr/bin/env bash
set -x

export PG_HOME=/root/pg18
export PATH=$PG_HOME/bin:$PATH
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

cd /app

# Create temp directory for regression tests if needed
mkdir -p /tmp/regress_tmp
export TMPDIR=/tmp/regress_tmp

# Run regression tests
make PG_CONFIG=$PG_HOME/bin/pg_config installcheck EXTRA_TESTS="pgvector fuzzystrmatch pg_trgm" 2>&1

# Capture exit code
MAKE_EXIT=$?

# Check for regression test diff files
if [ -f "regress/regression.diffs" ]; then
  echo "=== Regression test failures found ==="
  cat regress/regression.diffs
  echo "FINAL_STATUS = FAIL"
  exit 1
elif [ $MAKE_EXIT -ne 0 ]; then
  echo "=== Make command failed with exit code $MAKE_EXIT ==="
  if [ -f "regress/log/initdb.log" ]; then
    echo "=== initdb log ==="
    cat regress/log/initdb.log
  fi
  echo "FINAL_STATUS = FAIL"
  exit 1
else
  echo "=== Tests completed successfully ==="
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
