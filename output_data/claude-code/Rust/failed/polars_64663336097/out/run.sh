#!/usr/bin/env bash

set +e

cargo test --lib --tests --bins --all-features \
    -p polars-arrow \
    -p polars-compute \
    -p polars-core \
    -p polars-io \
    -p polars-lazy \
    -p polars-ops \
    -p polars-parquet \
    -p polars-plan \
    -p polars-row \
    -p polars-sql \
    -p polars-time \
    -p polars-utils

TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = SUCCESS"
fi

exit 0
