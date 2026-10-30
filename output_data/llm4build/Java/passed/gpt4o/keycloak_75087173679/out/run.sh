#!/bin/bash

# Clone the repository
git clone <repository-url> /app
cd /app

# Set up Java environment
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Prepare Quarkus distribution with current JDK
./mvnw install -e -pl testsuite/integration-arquillian/servers/auth-server/quarkus

# Run new base tests
./mvnw package -f tests/pom.xml -Dtest=JDKTestSuite

# Run base tests
TESTS=$(testsuite/integration-arquillian/tests/base/testsuites/suite.sh jdk)
echo "Tests: $TESTS"
./mvnw test -Dsurefire.rerunFailingTestsCount=2 -Pauth-server-quarkus -Dtest=$TESTS "-Dwebdriver.chrome.driver=$CHROMEWEBDRIVER/chromedriver" -pl testsuite/integration-arquillian/tests/base 2>&1 | misc/log/trimmer.sh

# Build with JDK
./mvnw install -e -DskipTests -DskipExamples -DskipProtoLock=true

# Run unit tests
./mvnw test -pl "$(.github/scripts/find-modules-with-unit-tests.sh)"