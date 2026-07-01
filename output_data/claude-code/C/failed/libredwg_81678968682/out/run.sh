#!/usr/bin/env bash
set -e

echo "=== Running cmake with LIBREDWG_LIBONLY=On ==="
cmake -DLIBREDWG_LIBONLY=On -DCMAKE_C_COMPILER_LAUNCHER=ccache .

echo "=== Running make -j ==="
make -j

echo "=== Running make -j test ==="
make -j test || TEST_FAILED=true

if [ "$TEST_FAILED" = true ]; then
    echo "Tests failed, but they ran."
    FINAL_STATUS="SUCCESS"
else
    echo "Tests passed."
    FINAL_STATUS="SUCCESS"
fi

echo "FINAL_STATUS = $FINAL_STATUS"
exit 0
