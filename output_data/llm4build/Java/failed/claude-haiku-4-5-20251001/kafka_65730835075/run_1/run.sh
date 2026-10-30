#!/bin/bash

set -e

# Print environment info
echo "=== Environment Info ==="
java -version
python --version
gradle --version 2>/dev/null || echo "Gradle will be initialized via wrapper"
echo ""

# Navigate to workspace
cd /workspace

# Run quarantined tests
echo "=== Running Quarantined Tests ==="
set +e
timeout 180m ./gradlew --build-cache --continue --no-scan \
  -PtestLoggingEvents=started,passed,skipped,failed \
  -PmaxParallelForks=2 \
  -PmaxTestRetries=1 -PmaxTestRetryFailures=3 \
  -PmaxQuarantineTestRetries=3 -PmaxQuarantineTestRetryFailures=0 \
  -Pkafka.test.catalog.file= \
  -PcommitId=xxxxxxxxxxxxxxxx \
  quarantinedTest
quarantined_exitcode="$?"
echo "Quarantined tests exit code: $quarantined_exitcode"
set -e

# Run main tests
echo ""
echo "=== Running JUnit Tests ==="
set +e
timeout 180m ./gradlew --build-cache --continue --no-scan \
  -PtestLoggingEvents=started,passed,skipped,failed \
  -PmaxParallelForks=2 \
  -PmaxTestRetries=1 -PmaxTestRetryFailures=3 \
  -PmaxQuarantineTestRetries=3 -PmaxQuarantineTestRetryFailures=0 \
  -Pkafka.test.catalog.file= \
  -PcommitId=xxxxxxxxxxxxxxxx \
  test
test_exitcode="$?"
echo "JUnit tests exit code: $test_exitcode"
set -e

# Parse JUnit tests
echo ""
echo "=== Parsing JUnit Test Results ==="
export GITHUB_WORKSPACE=/workspace
export JUNIT_REPORT_URL=""
export GRADLE_TEST_EXIT_CODE=$test_exitcode
export GRADLE_QUARANTINED_TEST_EXIT_CODE=$quarantined_exitcode

python .github/scripts/junit.py --export-test-catalog ./test-catalog || true

# Exit with test failure code if any tests failed
if [ $quarantined_exitcode -ne 0 ] || [ $test_exitcode -ne 0 ]; then
  echo ""
  echo "=== Test Execution Summary ==="
  echo "Quarantined tests exit code: $quarantined_exitcode"
  echo "JUnit tests exit code: $test_exitcode"
  exit 1
fi

echo ""
echo "=== All Tests Passed ==="
exit 0