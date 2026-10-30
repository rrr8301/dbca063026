#!/usr/bin/env bash
set -e

cd /app

export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export MAVEN_OPTS="-Dfile.encoding=UTF-8 -Duser.country=US -Duser.language=en"

echo "Building and testing with Maven..."
mvn verify --show-version --no-transfer-progress --settings settings.xml

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
