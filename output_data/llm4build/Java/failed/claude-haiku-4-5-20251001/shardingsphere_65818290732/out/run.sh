#!/bin/bash
set -e

# Set Maven options from workflow
export MAVEN_OPTS="-Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dspotless.apply.skip=true"

# Verify Java installation
java -version

# Build and run tests
# -T1C: single-threaded build (one core)
# -B: batch mode (non-interactive)
# -ntp: no transfer progress
# -fae: fail at end (run all tests even if some fail)
./mvnw clean install -T1C -B -ntp -fae