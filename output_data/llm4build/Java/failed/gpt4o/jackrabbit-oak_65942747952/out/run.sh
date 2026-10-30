#!/bin/bash

# Set environment variables based on branch and repository
if [ "$GITHUB_REF" = "refs/heads/trunk" ] && [ "$GITHUB_EVENT_NAME" = "push" ] && [ "$GITHUB_REPOSITORY_OWNER" = "apache" ]; then
    echo 'Running on main branch of the canonical repo'
    MVN_ADDITIONAL_OPTS="-DdeployAtEnd=true"
    MVN_GOAL="deploy"
else
    echo 'Running outside main branch/canonical repo'
    MVN_ADDITIONAL_OPTS=""
    MVN_GOAL="install"
fi

# Build the project using Maven
mvn -B $MVN_GOAL $MVN_ADDITIONAL_OPTS -Pcoverage,integrationTesting,javadoc -Dnsfixtures=SEGMENT_TAR,DOCUMENT_NS

# Ensure all tests are executed
if [ $? -ne 0 ]; then
    echo "Build or tests failed."
    exit 1
fi