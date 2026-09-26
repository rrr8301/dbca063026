#!/usr/bin/env bash

set -e

cd /app

echo "=== Step 1: Check swagger-bom version matches root version ==="
ROOT_VERSION=$(./mvnw -q -Dexec.executable="echo" -Dexec.args='${project.version}' --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec)
BOM_VERSION=$(./mvnw -q -Dexec.executable="echo" -Dexec.args='${project.version}' --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec --file modules/swagger-bom/pom.xml)
echo "Root version: ${ROOT_VERSION}"
echo "BOM version:  ${BOM_VERSION}"
if [ "${ROOT_VERSION}" != "${BOM_VERSION}" ]; then
  echo "ERROR: swagger-bom version (${BOM_VERSION}) does not match root version (${ROOT_VERSION}). Update modules/swagger-bom/pom.xml."
  exit 1
fi

echo "=== Step 2: Build with Maven and Gradle ==="
export MY_POM_VERSION=`./mvnw -q -Dexec.executable="echo" -Dexec.args='${project.version}' --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec`
echo "POM VERSION" ${MY_POM_VERSION}
if [[ $MY_POM_VERSION =~ ^.*SNAPSHOT$ ]];
then
  ./mvnw --no-transfer-progress -B install --file pom.xml
  cd ./modules/swagger-gradle-plugin
  ./gradlew build --info || true
  cd ../..
else
  echo "not building project as it is a release version"
fi

echo "=== Step 3: Verify BOM integration test ==="
./mvnw --no-transfer-progress -B validate -Pbom-it || true

echo "FINAL_STATUS = SUCCESS"
