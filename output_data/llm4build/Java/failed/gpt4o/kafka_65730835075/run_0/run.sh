#!/bin/bash

# Activate Python environment
source /usr/bin/python3.12

# Install project dependencies
pip install -r .github/scripts/requirements.txt

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
python .github/scripts/junit.py --export-test-catalog ./test-catalog >> $GITHUB_STEP_SUMMARY