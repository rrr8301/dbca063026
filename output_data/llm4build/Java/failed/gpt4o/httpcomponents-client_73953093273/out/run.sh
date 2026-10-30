#!/bin/bash

# Activate Java environment
export JAVA_HOME=$JAVA_HOME_17
export PATH=$JAVA_HOME/bin:$PATH

# Configure Maven toolchains
mkdir -p "${HOME}/.m2"
cat > "${HOME}/.m2/toolchains.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>1.8</version>
    </provides>
    <configuration>
      <jdkHome>$JAVA_HOME_8</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOF

# Build with Maven
mvn -V --file pom.xml --no-transfer-progress -DtrimStackTrace=false -Djunit.jupiter.execution.parallel.enabled=false -Dhc.build.toolchain.version="1.8" -Pdocker -Drat.skip=true -Dlicense.skip=true