#!/usr/bin/env bash
set -e

cd /app

echo "Running test..."
mvn test -B

echo "Running javadoc..."
mvn -P '!examples' javadoc:javadoc

echo "FINAL_STATUS = SUCCESS"
