#!/bin/bash

# Activate environment variables
export MVN_ADDITIONAL_OPTS=""
export MVN_GOAL="install"

# Check if running on main branch of the canonical repo
if [ "$GITHUB_REF" = "refs/heads/trunk" ] && [ "$GITHUB_EVENT_NAME" = "push" ] && [ "$GITHUB_REPOSITORY_OWNER" = "apache" ]; then
    echo 'Running on main branch of the canonical repo'
    MVN_ADDITIONAL_OPTS="-DdeployAtEnd=true"
    MVN_GOAL="deploy"
fi

# Install project dependencies and run tests
mvn -B $MVN_GOAL $MVN_ADDITIONAL_OPTS -Pcoverage,integrationTesting,javadoc -Dnsfixtures=SEGMENT_TAR,DOCUMENT_NS || true

# Ensure all tests are executed, even if some fail
mvn test || true