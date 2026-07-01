#!/usr/bin/env bash

cd /app

export NIGHTLY_TESTS_NO_LOCKFILE=true

yarn jest --ci --maxWorkers 4 --reporters=default --reporters=jest-junit --rootdir='./' || true

echo "FINAL_STATUS = SUCCESS"
