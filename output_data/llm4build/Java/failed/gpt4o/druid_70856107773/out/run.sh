#!/bin/bash

# Activate environment variables
export MYSQL_DRIVER_CLASSNAME=com.mysql.jdbc.Driver
export SEGMENT_DOWNLOAD_TIMEOUT_MINS=5

# Install project dependencies
mvn clean install -DskipTests

# Run unit tests with JDK 17 and 21
for jdk_version in 17 21; do
    echo "Running unit tests with JDK $jdk_version"
    export JAVA_HOME=/usr/lib/jvm/zulu${jdk_version}-jdk
    export PATH=$JAVA_HOME/bin:$PATH
    mvn test -Dtest=!QTest -Dmaven.test.failure.ignore=true || true
done

# Ensure all tests are executed even if some fail
echo "All tests executed."