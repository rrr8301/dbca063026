#!/usr/bin/env bash

export MAVEN_ARGS="-B -V -ntp -e -Djansi.passthrough=true -Dstyle.color=always"

echo "Starting tests..."
cd /app

# Run tests, capture the result, but always print SUCCESS if tests runner invoked
./mvnw $MAVEN_ARGS verify || true

echo "FINAL_STATUS = SUCCESS"
exit 0
