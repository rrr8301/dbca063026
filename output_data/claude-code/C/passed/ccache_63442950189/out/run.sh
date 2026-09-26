#!/usr/bin/env bash

set -e

cd /app
ci/build

echo "FINAL_STATUS = SUCCESS"
