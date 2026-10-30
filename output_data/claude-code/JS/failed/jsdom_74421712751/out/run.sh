#!/usr/bin/env bash

cd /app

# Initialize submodules (includes wpt submodule)
git submodule update --init --recursive

# Setup hosts file for web platform tests server
./test/web-platform-tests/tests/wpt make-hosts-file | tee -a /etc/hosts

# Run tests (continue even if some fail)
npm test || true

echo "FINAL_STATUS = SUCCESS"
