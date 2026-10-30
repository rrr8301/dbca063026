#!/usr/bin/env bash

cd /app

export LD_LIBRARY_PATH=/usr/local/lib
make tests

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi
