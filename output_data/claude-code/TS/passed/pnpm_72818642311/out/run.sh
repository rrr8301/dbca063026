#!/usr/bin/env bash
set -e

cd /app

# Since this commit is on main branch, use ci:test-all
echo "Running tests with ci:test-all"
pn run ci:test-all

echo "FINAL_STATUS = SUCCESS"
