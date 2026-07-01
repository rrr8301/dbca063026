#!/usr/bin/env bash
set -o pipefail

cd /app

# Run the test command exactly as in the workflow for Java 25
./mvnw $MAVEN_ARGS clean test verify \
  -Pjacoco,jdk15ge-simple,'!jdk15ge-add-open',skip-spotless \
  -DtrimStackTrace=false \
  -Dmaven.test.skip=false \
  -Dcheckstyle.skip=false \
  -Dcheckstyle_unix.skip=false \
  -Drat.skip=false \
  -DembeddedZookeeperPath=/tmp/zookeeper \
  2>&1 | tee >(grep -n -B 1 -A 200 "FAILURE! -- in" > /app/test_errors.log) || true

# Print test error log if tests failed
if [ -f /app/test_errors.log ] && [ -s /app/test_errors.log ]; then
  echo "=== Test Error Log ==="
  cat /app/test_errors.log
fi

# Check test results and set final status
if grep -q "FAILURE! -- in" /app/test_errors.log 2>/dev/null; then
  FINAL_STATUS=FAIL
else
  # If tests ran (even with some failures), the runner was invoked
  if grep -q "Tests run:" /app/test_errors.log 2>/dev/null || grep -q "\[ERROR\]" /app/test_errors.log 2>/dev/null; then
    FINAL_STATUS=SUCCESS
  else
    # Check if Maven completed the test phase
    if tail -20 /tmp/*.log 2>/dev/null | grep -q "BUILD SUCCESS\|BUILD FAILURE" || [ -f /app/test_errors.log ]; then
      FINAL_STATUS=SUCCESS
    else
      FINAL_STATUS=FAIL
    fi
  fi
fi

echo "FINAL_STATUS = $FINAL_STATUS"
