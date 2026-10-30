#!/usr/bin/env bash

export HC_BUILD_TOOLCHAIN_VERSION=1.8
export TOOLCHAIN_JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

mkdir -p "${HOME}/.m2"
cat > "${HOME}/.m2/toolchains.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>${HC_BUILD_TOOLCHAIN_VERSION}</version>
    </provides>
    <configuration>
      <jdkHome>${TOOLCHAIN_JAVA_HOME}</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOF

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

cd /app
./mvnw -V --file pom.xml --no-transfer-progress -DtrimStackTrace=false -Djunit.jupiter.execution.parallel.enabled=false -Dhc.build.toolchain.version="${HC_BUILD_TOOLCHAIN_VERSION}" -Pdocker

echo "FINAL_STATUS = SUCCESS"
