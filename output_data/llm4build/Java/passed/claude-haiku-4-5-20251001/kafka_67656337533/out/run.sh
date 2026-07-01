#!/bin/bash
set -e

# Set default values for environment variables if not provided
TIMEOUT_MINUTES=${TIMEOUT_MINUTES:-180}
TEST_CATALOG=${TEST_CATALOG:-.github/scripts/test-catalog.txt}
TEST_TASK=${TEST_TASK:-test}
TEST_RETRIES=${TEST_RETRIES:-1}
TEST_REPEAT=${TEST_REPEAT:-1}
RUN_NEW_TESTS=${RUN_NEW_TESTS:-false}
RUN_FLAKY_TESTS=${RUN_FLAKY_TESTS:-false}
TEST_XML_OUTPUT_DIR=${TEST_XML_OUTPUT_DIR:-build/junit-xml}
TEST_VERBOSE=${TEST_VERBOSE:-false}

# Validate TIMEOUT_MINUTES is a number
if ! [[ "$TIMEOUT_MINUTES" =~ ^[0-9]+$ ]]; then
    echo "Error: TIMEOUT_MINUTES must be a positive integer, got: $TIMEOUT_MINUTES"
    exit 1
fi

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