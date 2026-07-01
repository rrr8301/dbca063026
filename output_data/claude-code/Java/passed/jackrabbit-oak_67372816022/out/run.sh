#!/usr/bin/env bash

cd /app

# Run the exact Maven build command from the workflow
mvn -B install -Pcoverage,integrationTesting,javadoc -Dnsfixtures=SEGMENT_TAR,DOCUMENT_NS

BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
