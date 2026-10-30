#!/bin/bash

# Activate environment variables if needed (none specified)

# Install project dependencies and build
mvn -T 1C -B clean install -DskipTests

# Run tests for each module
modules=("core" "flink" "spark3" "lake")
for module in "${modules[@]}"; do
    TEST_MODULES=$(./.github/workflows/stage.sh $module)
    echo "Start testing modules: $TEST_MODULES"
    mvn -B verify $TEST_MODULES -Ptest-coverage -Ptest-$module -Dlog.dir=/tmp/fluss-logs -Dlog4j.configurationFile=tools/ci/log4j.properties -Denforcer.skip=true || true
done