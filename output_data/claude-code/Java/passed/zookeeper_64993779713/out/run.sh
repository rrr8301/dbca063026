#!/usr/bin/env bash

set -e

cd /app

echo "=== Running Maven Tests ==="
mvn -B -V -e -ntp "-Dstyle.color=always" -Pfull-build verify -Dsurefire-forkcount=1 -DskipCppUnit -Dsurefire.rerunFailingTestsCount=5

echo ""
echo "FINAL_STATUS = SUCCESS"
