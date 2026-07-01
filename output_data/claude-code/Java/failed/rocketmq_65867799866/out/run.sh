#!/usr/bin/env bash
set -e

cd /app

echo "Starting Maven build..."
mvn -B package --file pom.xml

echo "FINAL_STATUS = SUCCESS"
