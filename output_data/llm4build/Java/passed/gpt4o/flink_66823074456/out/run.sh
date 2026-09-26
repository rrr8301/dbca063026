#!/bin/bash

# Activate environment variables
export JAVA_HOME=$JAVA_HOME_17_X64
export PATH=$JAVA_HOME/bin:$PATH

# Install project dependencies
./mvnw clean package -DskipTests -Djdk17 -Pjava17-target -Denforcer.skip=true -Drat.skip=true

# Unpack build artifacts
./tools/azure-pipelines/unpack_build_artifact.sh

# Run tests for each module
PROFILE="-Dinclude_hadoop_aws -Djdk17 -Pjava17-target -Pgithub-actions"

# Test core module
PROFILE="$PROFILE" ./tools/azure-pipelines/uploading_watchdog.sh ./tools/ci/test_controller.sh core

# Test python module
if [[ "$1" == "python" ]]; then
    PROFILE="$PROFILE" ./tools/azure-pipelines/uploading_watchdog.sh ./tools/ci/test_controller.sh python
fi

# Test other modules as needed
# Add similar blocks for table, connect, tests, misc modules if needed