#!/usr/bin/env bash
set -e

cd /app

echo "=== Updating /etc/hosts ==="
printf "\n\n" >> /etc/hosts
cat .github/actions/update-hosts/hosts >> /etc/hosts

echo "=== Building tar keycloak-quarkus-dist ==="
./mvnw package -pl quarkus/server/,quarkus/dist/ ${MAVEN_ARGS} || {
    echo "Build tar failed, trying to build the full project first..."
    ./mvnw install dependency:resolve -V -e -DskipTests -DskipExamples -DexcludeGroupIds=org.keycloak -Dsilent=true -DcommitProtoLockChanges=true ${MAVEN_ARGS}
    ./mvnw package -pl quarkus/server/,quarkus/dist/ ${MAVEN_ARGS}
}

echo "=== Running Base1TestSuite tests ==="
./mvnw package -f tests/pom.xml -Dtest=Base1TestSuite ${MAVEN_ARGS} ${SUREFIRE_RETRY} 2>&1 | tee test_output.log || true

if grep -q "FAILURE\|BUILD FAILURE" test_output.log; then
    echo "FINAL_STATUS = FAIL"
    exit 1
else
    echo "FINAL_STATUS = SUCCESS"
    exit 0
fi
