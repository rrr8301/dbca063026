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

# Verify Maven is installed
mvn -version

# Verify Node.js is installed
node --version
npm --version

# Step 1: Build with JDK (skip tests initially to build all artifacts)
echo "=== Building with JDK (skipping tests) ==="
mvn install -e -DskipTests -DskipExamples -DskipProtoLock=true -Drat.skip=true -Dlicense.skip=true

# Step 2: Prepare Quarkus distribution with current JDK (now that keycloak-quarkus-dist exists)
echo "=== Preparing Quarkus distribution with current JDK ==="
mvn install -e -pl testsuite/integration-arquillian/servers/auth-server/quarkus -Drat.skip=true -Dlicense.skip=true

# Step 3: Run new base tests
echo "=== Running new base tests ==="
mvn package -f tests/pom.xml -Dtest=JDKTestSuite -Drat.skip=true -Dlicense.skip=true

# Step 4: Run base tests
echo "=== Running base tests ==="
TESTS=$(testsuite/integration-arquillian/tests/base/testsuites/suite.sh jdk)
echo "Tests: $TESTS"
mvn test $SUREFIRE_RETRY -Pauth-server-quarkus -Dtest=$TESTS "-Dwebdriver.chrome.driver=$CHROMEWEBDRIVER/chromedriver" -pl testsuite/integration-arquillian/tests/base -Drat.skip=true -Dlicense.skip=true 2>&1 | misc/log/trimmer.sh || true

# Step 5: Run unit tests
echo "=== Running unit tests ==="
UNIT_TEST_MODULES=$(.github/scripts/find-modules-with-unit-tests.sh)
if [ -n "$UNIT_TEST_MODULES" ]; then
  mvn test -pl "$UNIT_TEST_MODULES" -Drat.skip=true -Dlicense.skip=true
else
  echo "No modules with unit tests found"
fi

echo "=== All tests completed ==="