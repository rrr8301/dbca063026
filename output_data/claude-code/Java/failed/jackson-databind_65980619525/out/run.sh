#!/usr/bin/env bash

set -e

export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Run the build
./mvnw -B -ff -ntp verify

echo "FINAL_STATUS = SUCCESS"
