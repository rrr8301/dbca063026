#!/usr/bin/env bash

set +e

export ROOT_POM="pom.xml"

echo "Running Install step..."
./mvnw -B -ntp -Dtoolchain.skip install -U -DskipTests=true -f $ROOT_POM
INSTALL_EXIT=$?

echo ""
echo "Running Test step..."
./mvnw -B -ntp -P!standard-with-extra-repos -Dtoolchain.skip verify -U -Dmaven.javadoc.skip=true -Dsurefire.toolchain.version=11 -f $ROOT_POM
TEST_EXIT=$?

echo ""
echo "Install exit code: $INSTALL_EXIT"
echo "Test exit code: $TEST_EXIT"

if [ $TEST_EXIT -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
fi
