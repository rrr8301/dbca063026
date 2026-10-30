#!/bin/bash

# Ensure Python 3 is used
PYTHON_BIN=$(which python3)

# Install project dependencies
$PYTHON_BIN -m pip install -r .github/scripts/requirements.txt

# Run JUnit Quarantined Tests
timeout 180m ./gradlew --build-cache --continue --no-scan \
    -PtestLoggingEvents=started,passed,skipped,failed \
    -PmaxParallelForks=2 \
    -PmaxTestRetries=1 -PmaxTestRetryFailures=3 \
    -PmaxQuarantineTestRetries=3 -PmaxQuarantineTestRetryFailures=0 \
    -Pkafka.test.catalog.file=./test-catalog/combined-test-catalog.txt \
    -PcommitId=xxxxxxxxxxxxxxxx \
    quarantinedTest

# Run JUnit Tests
timeout 180m ./gradlew --build-cache --continue --no-scan \
    -PtestLoggingEvents=started,passed,skipped,failed \
    -PmaxParallelForks=2 \
    -PmaxTestRetries=1 -PmaxTestRetryFailures=3 \
    -PmaxQuarantineTestRetries=3 -PmaxQuarantineTestRetryFailures=0 \
    -Pkafka.test.catalog.file=./test-catalog/combined-test-catalog.txt \
    -PcommitId=xxxxxxxxxxxxxxxx \
    test

# Parse JUnit tests
$PYTHON_BIN .github/scripts/junit.py --export-test-catalog ./test-catalog >> $GITHUB_STEP_SUMMARY