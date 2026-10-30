#!/usr/bin/env bash
set -e

cd /app

# Set environment variables for PR build (not on main branch, so install goal)
MVN_ADDITIONAL_OPTS=""
MVN_GOAL="install"

# Run Maven build with the same flags as GitHub Actions
mvn -B $MVN_GOAL $MVN_ADDITIONAL_OPTS -Pcoverage,integrationTesting,javadoc -Dnsfixtures=SEGMENT_TAR,DOCUMENT_NS

echo "FINAL_STATUS = SUCCESS"
