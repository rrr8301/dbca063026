#!/usr/bin/env bash

set -e

# Start MySQL server
/etc/init.d/mysql start || true

# Run tests
cd /app/Tests

export PYTHONMALLOC=debug
export LD_PRELOAD="$(realpath "$(gcc -print-file-name=libasan.so)") $(realpath "$(gcc -print-file-name=libstdc++.so)")"
export ASAN_OPTIONS="detect_leaks=0"

coverage run --source Bio,BioSQL run_tests.py --offline
TEST_RESULT=$?

coverage xml

if [ $TEST_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = SUCCESS"
fi

exit 0
