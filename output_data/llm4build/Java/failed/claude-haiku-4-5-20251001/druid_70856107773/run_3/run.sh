#!/bin/bash
set -e

# Run Maven tests excluding QTest and matching the pattern
mvn clean test \
  -Dtest="!QTest,'$PATTERN'" \
  -Dmaven.test.failure.ignore=true