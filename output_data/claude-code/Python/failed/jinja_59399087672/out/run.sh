#!/usr/bin/env bash

cd /app

python3.12 -m uv run --locked tox run -e py312

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi
