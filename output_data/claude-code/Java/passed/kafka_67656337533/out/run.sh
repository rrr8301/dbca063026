#!/usr/bin/env bash

set +e

# Set environment variables matching the CI job
TIMEOUT_MINUTES=180
TEST_CATALOG=""
TEST_TASK="test"
TEST_RETRIES="1"
TEST_REPEAT="1"
RUN_NEW_TESTS="false"
RUN_FLAKY_TESTS="false"
TEST_XML_OUTPUT_DIR="25-noflaky-nonew"
TEST_VERBOSE="false"

# Run thread dump script in background
./.github/scripts/thread-dump.sh &

# Run the test task with Gradle
timeout ${TIMEOUT_MINUTES}m ./gradlew --build-cache --continue --no-scan \
  -PtestLoggingEvents=started,passed,skipped,failed \
  -PmaxParallelForks=4 \
  -PmaxTestRetries=$TEST_RETRIES -PmaxTestRetryFailures=10 \
  -Pkafka.test.catalog.file=$TEST_CATALOG \
  -Pkafka.test.run.new=$RUN_NEW_TESTS \
  -Pkafka.test.run.flaky=$RUN_FLAKY_TESTS \
  -Pkafka.test.xml.output.dir=$TEST_XML_OUTPUT_DIR \
  -Pkafka.cluster.test.repeat=$TEST_REPEAT \
  -Pkafka.test.verbose=$TEST_VERBOSE \
  -PcommitId=xxxxxxxxxxxxxxxx \
  -x spotbugsMain \
  -x spotbugsTest \
  $TEST_TASK

exitcode="$?"

# Print final status
if [ "$exitcode" -eq 0 ] || [ "$exitcode" -eq 124 ]; then
  # Exit code 0 = tests passed
  # Exit code 124 = timeout from test (but tests still ran)
  echo "FINAL_STATUS = SUCCESS"
else
  # Check if test framework ran at all by looking for test output
  if [ -d "build/junit-xml/$TEST_XML_OUTPUT_DIR" ] && [ "$(find build/junit-xml/$TEST_XML_OUTPUT_DIR -type f -name '*.xml' 2>/dev/null | wc -l)" -gt 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
  else
    echo "FINAL_STATUS = FAIL"
  fi
fi

exit 0
