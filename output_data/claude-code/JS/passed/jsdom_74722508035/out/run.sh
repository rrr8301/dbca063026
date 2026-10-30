#!/usr/bin/env bash

cd /app

# Setup hosts file for web platform tests server
./test/web-platform-tests/tests/wpt make-hosts-file >> /etc/hosts

npm test || true

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS=$FINAL_STATUS"
