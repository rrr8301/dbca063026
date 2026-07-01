#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit status
TEST_FAILED=0

# Navigate to workspace
cd /workspace

# Display Java and Maven versions
echo "=== Java Version ==="
java -version

echo "=== Maven Version ==="
mvn -version

# Setup test profiling environment (simulate the GitHub Actions script)
echo "=== Setting up test profiling environment ==="
if [ -f ./.github/scripts/setup_test_profiling_env.sh ]; then
    # Source the setup script to set environment variables
    # Note: This script may reference GitHub-specific variables; we provide defaults
    export GITHUB_RUN_ID="${GITHUB_RUN_ID:-local-run}"
    export GITHUB_RUN_NUMBER="${GITHUB_RUN_NUMBER:-1}"
    export GITHUB_RUN_ATTEMPT="${GITHUB_RUN_ATTEMPT:-1}"
    export GITHUB_EVENT_REF="${GITHUB_EVENT_REF:-local-test}"
    export GITHUB_RUN_URL="${GITHUB_RUN_URL:-http://localhost}"
    
    # Capture the output and parse it for MAVEN_OPTS
    # The setup script outputs KEY=VALUE format for GitHub ENV
    SETUP_OUTPUT=$(bash ./.github/scripts/setup_test_profiling_env.sh 21 \
        run_id=$GITHUB_RUN_ID \
        run_number=$GITHUB_RUN_NUMBER \
        run_attempt=$GITHUB_RUN_ATTEMPT \
        key="unit-tests-D*,H*,L*" \
        event_ref=$GITHUB_EVENT_REF \
        run_url=$GITHUB_RUN_URL 2>/dev/null || true)
    
    # Extract JFR_PROFILER_ARG_LINE from the output if it exists
    if [ -n "$SETUP_OUTPUT" ]; then
        # Parse the output to extract JFR_PROFILER_ARG_LINE value
        JFR_PROFILER_ARG_LINE=$(echo "$SETUP_OUTPUT" | grep "^JFR_PROFILER_ARG_LINE=" | cut -d'=' -f2- || true)
        
        if [ -n "$JFR_PROFILER_ARG_LINE" ]; then
            export MAVEN_OPTS="$JFR_PROFILER_ARG_LINE"
            echo "MAVEN_OPTS set to: $MAVEN_OPTS"
        fi
    fi
fi

# Start jstack collection in background (if script exists)
if [ -f ./.github/scripts/collect_jstacks ]; then
    bash ./.github/scripts/collect_jstacks &
fi

# Run unit tests for modules matching D*, H*, L*
echo "=== Running Unit Tests for D*, H*, L* ==="
if [ -f ./.github/scripts/run_unit-tests ]; then
    bash ./.github/scripts/run_unit-tests \
        -Dtest='!QTest,D*,H*,L*' \
        -Dmaven.test.failure.ignore=true || TEST_FAILED=1
else
    # Fallback: run Maven directly if script doesn't exist
    mvn clean test \
        -Dtest='!QTest,D*,H*,L*' \
        -Dmaven.test.failure.ignore=true || TEST_FAILED=1
fi

# Collect test reports
echo "=== Collecting Test Reports ==="
if [ -d target/surefire-reports ]; then
    find . -name "TEST-*.xml" -type f
fi

# Exit with appropriate status
if [ $TEST_FAILED -eq 1 ]; then
    echo "=== Tests completed with failures ==="
    exit 1
else
    echo "=== All tests passed ==="
    exit 0
fi