#!/bin/bash

set -e

# Enable error handling
trap 'echo "Build failed with exit code $?"' ERR

echo "=========================================="
echo "Starting Pulsar Integration Tests - MESSAGING"
echo "=========================================="

# Set environment variables for the test run
export JOB_NAME="CI - Integration - Messaging"
export PULSAR_TEST_IMAGE_NAME="apachepulsar/java-test-image:latest"
export CI_JDK_MAJOR_VERSION="21"
export NETTY_LEAK_DETECTION="report"
export NETTY_LEAK_DUMP_DIR="${PWD}/target/netty-leak-dumps"
export DEVELOCITY_ACCESS_KEY=""

# Verify Java installation
echo "::group::Java Version"
java -version
echo "::endgroup::"

# Verify Maven installation
echo "::group::Maven Version"
mvn -version
echo "::endgroup::"

# Create necessary directories
mkdir -p "${NETTY_LEAK_DUMP_DIR}"
mkdir -p test-reports
mkdir -p surefire-reports

# Navigate to workspace
cd /workspace

echo "::group::Building Maven dependencies"
# Build the project and download dependencies
# This ensures all Maven artifacts are available locally
mvn clean install -DskipTests -Drat.skip=true -Dlicense.skip=true -q || true
echo "::endgroup::"

echo "::group::Running Integration Tests - MESSAGING"
# Run the integration test group 'MESSAGING'
# This is the exact command from the workflow
./build/run_integration_group.sh MESSAGING
TEST_EXIT_CODE=$?
echo "::endgroup::"

echo "::group::Aggregating Test Reports"
# Aggregate test reports using the custom action logic
$GITHUB_WORKSPACE/build/pulsar_ci_tool.sh move_test_reports || true
echo "::endgroup::"

echo "::group::Reporting Netty Leaks"
# Report detected Netty leaks if detection is enabled
if [[ "${NETTY_LEAK_DETECTION}" != "off" ]]; then
    $GITHUB_WORKSPACE/build/pulsar_ci_tool.sh report_netty_leaks || true
fi
echo "::endgroup::"

echo "=========================================="
echo "Integration Tests - MESSAGING Complete"
echo "=========================================="

# Exit with the test result code
exit $TEST_EXIT_CODE