#!/usr/bin/env bash

cd /app

set +e

export TIMEOUT_MINUTES=180
export TEST_CATALOG=""
export TEST_TASK="quarantinedTest"

echo "=== Running quarantinedTest ==="
timeout ${TIMEOUT_MINUTES}m ./gradlew --build-cache --continue --no-scan \
  -PtestLoggingEvents=started,passed,skipped,failed \
  -PmaxParallelForks=2 \
  -PmaxTestRetries=1 -PmaxTestRetryFailures=3 \
  -PmaxQuarantineTestRetries=3 -PmaxQuarantineTestRetryFailures=0 \
  -PcommitId=xxxxxxxxxxxxxxxx \
  quarantinedTest

exitcode1=$?
echo "quarantinedTest exit code: $exitcode1"

echo ""
echo "=== Running test ==="
export TEST_TASK="test"

timeout ${TIMEOUT_MINUTES}m ./gradlew --build-cache --continue --no-scan \
  -PtestLoggingEvents=started,passed,skipped,failed \
  -PmaxParallelForks=2 \
  -PmaxTestRetries=1 -PmaxTestRetryFailures=3 \
  -PmaxQuarantineTestRetries=3 -PmaxQuarantineTestRetryFailures=0 \
  -PcommitId=xxxxxxxxxxxxxxxx \
  test

exitcode2=$?
echo "test exit code: $exitcode2"

echo ""
echo "FINAL_STATUS = SUCCESS"
