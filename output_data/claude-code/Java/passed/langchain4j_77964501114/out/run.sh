#!/usr/bin/env bash

set -o pipefail

echo "=== Maven version ==="
./mvnw --version

echo "=== Compiling and running unit tests ==="
./mvnw -B -U -DembeddingsSkipCache -T8C test javadoc:aggregate 2>&1 | tee maven-output.log

test_result=${PIPESTATUS[0]}

if [ $test_result -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi

exit $test_result
