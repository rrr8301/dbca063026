#!/usr/bin/env bash

set -x

cd /app

# Set up environment variables similar to worker.yml
export HASH=$(echo -n "test-jdk21-[D*,H*,L*]" | sha256sum | cut -c-8)

# Run setup profiling environment script
./.github/scripts/setup_test_profiling_env.sh 21 run_id=1 run_number=1 run_attempt=1 key="test-jdk21-[D*,H*,L*]" event_ref="push-master" run_url="https://github.com/apache/druid/actions/runs/23260289875" > /tmp/jfr_env.txt 2>&1

# Source the environment
source /tmp/jfr_env.txt || true

# Extract JFR_PROFILER_ARG_LINE
JFR_PROFILER_ARG_LINE=$(grep "^JFR_PROFILER_ARG_LINE=" /tmp/jfr_env.txt | cut -d'=' -f2- || echo "")
export JFR_PROFILER_ARG_LINE

# Run unit tests
OPTS=" -Dsurefire.failIfNoSpecifiedTests=false -P skip-static-checks -Dweb.console.skip=true"
OPTS+=" -Djacoco.destFile=target/jacoco-${HASH}.exec"

mvn -B $OPTS test "-DjfrProfilerArgLine=${JFR_PROFILER_ARG_LINE}" \
  -Dtest=!QTest,'D*,H*,L*' \
  -Dmaven.test.failure.ignore=true

# Check if tests ran successfully
if [ $? -eq 0 ] || [ -f "target/surefire-reports/TEST-*.xml" ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
