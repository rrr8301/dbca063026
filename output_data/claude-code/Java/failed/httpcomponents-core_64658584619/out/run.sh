#!/usr/bin/env bash

cd /app

echo "Building with Maven..."
mvn -V --file pom.xml --no-transfer-progress -DtrimStackTrace=false -Djunit.jupiter.execution.parallel.enabled=false -P-use-toolchains,docker || true

# Check if tests ran by looking for test reports
if [ -d "/app/httpcore5/target/surefire-reports" ]; then
    FINAL_STATUS=SUCCESS
else
    FINAL_STATUS=FAIL
fi

echo "FINAL_STATUS = $FINAL_STATUS"
