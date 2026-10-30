#!/usr/bin/env bash

set -e

cd /app

tox -e ci-py311 -- -v --color=yes -n 0

echo "FINAL_STATUS = SUCCESS"
