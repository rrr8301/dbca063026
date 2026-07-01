#!/bin/bash

set -e

# Export environment variables from the job
export MAVEN_ARGS="-B -nsu -Daether.connector.http.connectionMaxTtl=25"
export SUREFIRE_RERUN_FAILING_COUNT=2
export SUREFIRE_RETRY="-Dsurefire.rerunFailingTestsCount=2"
export KC_TEST_GITHUB_SLOW_METHOD="10"
export KC_TEST_GITHUB_SLOW_CLASS="60"
export CHROMEWEBDRIVER=/usr/lib/chromium-browser

# Update /etc/hosts (from update-hosts action)
if [ -f .github/actions/update-hosts/hosts ]; then
  echo "" | sudo tee -a /etc/hosts > /dev/null
  cat .github/actions/update-hosts/hosts | sudo tee -a /etc/hosts > /dev/null
fi

# Verify Java is installed
java -version

# Step 1: Prepare Quarkus distribution with current JDK
echo "=== Preparing Quarkus distribution with current JDK ==="
./mvnw install -e -pl testsuite/integration-arquillian/servers/auth-server/quarkus

# Step 2: Run new base tests
echo "=== Running new base tests ==="
./mvnw package -f tests/pom.xml -Dtest=JDKTestSuite

# Step 3: Run base tests
echo "=== Running base tests ==="
TESTS=$(testsuite/integration-arquillian/tests/base/testsuites/suite.sh jdk)
echo "Tests: $TESTS"
./mvnw test $SUREFIRE_RETRY -Pauth-server-quarkus -Dtest=$TESTS "-Dwebdriver.chrome.driver=$CHROMEWEBDRIVER/chromedriver" -pl testsuite/integration-arquillian/tests/base 2>&1 | misc/log/trimmer.sh || true

# Step 4: Build with JDK (skip tests)
echo "=== Building with JDK (skipping tests) ==="
./mvnw install -e -DskipTests -DskipExamples -DskipProtoLock=true

# Step 5: Run unit tests
echo "=== Running unit tests ==="
UNIT_TEST_MODULES=$(.github/scripts/find-modules-with-unit-tests.sh)
if [ -n "$UNIT_TEST_MODULES" ]; then
  ./mvnw test -pl "$UNIT_TEST_MODULES"
else
  echo "No modules with unit tests found"
fi

echo "=== All tests completed ==="