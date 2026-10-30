#!/usr/bin/env bash

set -e

cd /app

echo "=== Starting Zookeeper full-build-java-tests ==="

mvn -B -V -e -ntp "-Dstyle.color=always" \
  -Pfull-build verify \
  -Dsurefire-forkcount=1 \
  -DskipCppUnit \
  -Dsurefire.rerunFailingTestsCount=5

echo "FINAL_STATUS = SUCCESS"
