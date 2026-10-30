#!/usr/bin/env bash

set -e

# Set environment variables
export DEBUG_FILES_OUTPUT_DIR=/tmp/debug-files
mkdir -p $DEBUG_FILES_OUTPUT_DIR

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

export MAVEN_REPO_FOLDER=/root/.m2/repository
export MAVEN_ARGS=-Dmaven.repo.local=/root/.m2/repository
export DOCKER_IMAGES_CACHE_FOLDER=/root/.docker-cache

# Set core dump pattern
ulimit -c unlimited

# Print environment info
echo "Java version:"
java -version

echo "Maven version:"
mvn -version

echo "Git info:"
cd /root/flink
git log -1 --oneline

# Run the test controller for the core module
export PROFILE="-Dinclude_hadoop_aws -Djdk17 -Pjava17-target"

echo "Running tests for core module..."
cd /root/flink

# Run the test controller script
bash ./tools/ci/test_controller.sh core

# Check the exit code
TEST_EXIT_CODE=$?

# Print final status
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit $TEST_EXIT_CODE
fi
