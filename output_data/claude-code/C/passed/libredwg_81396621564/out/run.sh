#!/usr/bin/env bash
set -e

cd /app

# Run the exact cmake command from the workflow
cmake -DLIBREDWG_LIBONLY=On -DCMAKE_C_COMPILER_LAUNCHER=ccache .

# Build with make -j
make -j

# Run tests with make -j test
make -j test

# If we got here, tests ran successfully
echo "FINAL_STATUS = SUCCESS"
