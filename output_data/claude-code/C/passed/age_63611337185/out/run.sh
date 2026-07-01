#!/usr/bin/env bash
set -e

cd /app

export PG_CONFIG=/usr/local/pg18/bin/pg_config
export PATH="/usr/local/pg18/bin:${PATH}"
export LD_LIBRARY_PATH="/usr/local/pg18/lib:${LD_LIBRARY_PATH}"

echo "Running AGE regression tests..."
make PG_CONFIG=$PG_CONFIG installcheck EXTRA_TESTS="pgvector fuzzystrmatch pg_trgm" || FAILED=1

if [ -n "$FAILED" ]; then
  echo "Dump section begin."
  if [ -f /app/regress/log/initdb.log ]; then
    echo "=== initdb.log ==="
    cat /app/regress/log/initdb.log
    echo "=== end initdb.log ==="
  fi
  if [ -f /app/regress/regression.diffs ]; then
    echo "=== regression.diffs ==="
    cat /app/regress/regression.diffs
    echo "=== end regression.diffs ==="
  fi
  echo "Dump section end."
fi

if [ -z "$FAILED" ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
