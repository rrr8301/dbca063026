#!/bin/bash

# Set up environment variables
export JOB_NAME="CI - Integration - Messaging"
export PULSAR_TEST_IMAGE_NAME="apachepulsar/java-test-image:latest"
export CI_JDK_MAJOR_VERSION=17
export NETTY_LEAK_DETECTION="report"
export NETTY_LEAK_DUMP_DIR="/app/target/netty-leak-dumps"

# Install project dependencies
mvn clean install -Drat.skip=true -Dlicense.skip=true

# Run integration test group 'MESSAGING'
./build/run_integration_group.sh MESSAGING

# Report detected Netty leaks
/app/build/pulsar_ci_tool.sh report_netty_leaks