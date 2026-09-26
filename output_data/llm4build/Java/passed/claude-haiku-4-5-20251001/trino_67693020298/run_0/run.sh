#!/bin/bash

set -euo pipefail

# Set environment variables
export CONTINUOUS_INTEGRATION=true
export MAVEN=./mvnw
export MAVEN_OPTS="-Xmx512M -XX:+ExitOnOutOfMemoryError"
export MAVEN_INSTALL_OPTS="-Xmx3G -XX:+ExitOnOutOfMemoryError"
export MAVEN_FAST_INSTALL="-B -V -T 1C -DskipTests -Dmaven.source.skip=true -Dair.check.skip-all"
export MAVEN_COMPILE_COMMITS="-B --quiet -T 1C -DskipTests -Dmaven.source.skip=true -Dair.check.skip-all=true -Dmaven.javadoc.skip=true --no-snapshot-updates --no-transfer-progress"
export MAVEN_GIB="-P gib -Dgib.referenceBranch=refs/remotes/origin/master"
export MAVEN_TEST="-B -Dmaven.source.skip=true -Dair.check.skip-all --fail-at-end -P gib -Dgib.referenceBranch=refs/remotes/origin/master"
export TESTCONTAINERS_PULL_PAUSE_TIMEOUT=600
export SEGMENT_DOWNLOAD_TIMEOUT_MINS=5
export PTL_TMP_DOWNLOAD_PATH=/tmp/pt_java_downloads

# Create temp directory if needed
mkdir -p "$PTL_TMP_DOWNLOAD_PATH"

echo "=========================================="
echo "Verifying Java installation"
echo "=========================================="
java -version

echo "=========================================="
echo "Verifying Maven installation"
echo "=========================================="
$MAVEN --version

echo "=========================================="
echo "Verifying Node.js installation"
echo "=========================================="
node --version
npm --version

echo "=========================================="
echo "Fetching base ref for GIB"
echo "=========================================="
if [ -f ".github/bin/git-fetch-base-ref.sh" ]; then
    bash .github/bin/git-fetch-base-ref.sh || true
else
    echo "git-fetch-base-ref.sh not found, skipping"
fi

echo "=========================================="
echo "Maven Install (Fast Install)"
echo "=========================================="
export MAVEN_OPTS="${MAVEN_INSTALL_OPTS}"
$MAVEN clean install ${MAVEN_FAST_INSTALL} ${MAVEN_GIB} -am -pl "core/trino-main" || {
    echo "Maven install failed"
    exit 1
}

echo "=========================================="
echo "Maven Tests"
echo "=========================================="
export MAVEN_OPTS="-Xmx512M -XX:+ExitOnOutOfMemoryError"
TEST_RESULT=0
$MAVEN test ${MAVEN_TEST} -pl core/trino-main || TEST_RESULT=$?

echo "=========================================="
echo "Test Summary"
echo "=========================================="
if [ $TEST_RESULT -eq 0 ]; then
    echo "All tests passed!"
else
    echo "Some tests failed (exit code: $TEST_RESULT)"
fi

# Collect test results for inspection
echo "=========================================="
echo "Collecting test results"
echo "=========================================="
if [ -d "core/trino-main/target/surefire-reports" ]; then
    echo "Test reports found in core/trino-main/target/surefire-reports"
    find core/trino-main/target/surefire-reports -name "*.xml" -o -name "*.txt" | head -20
else
    echo "No test reports directory found"
fi

# Exit with test result code
exit $TEST_RESULT