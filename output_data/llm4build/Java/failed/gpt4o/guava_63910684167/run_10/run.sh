#!/bin/bash

# Navigate to the app directory
cd /app

# Create a toolchains.xml file for Maven
mkdir -p ~/.m2
cat <<EOL > ~/.m2/toolchains.xml
<?xml version="1.0" encoding="UTF-8"?>
<toolchains xmlns="http://maven.apache.org/TOOLCHAINS/1.1.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/TOOLCHAINS/1.1.0
                                http://maven.apache.org/xsd/toolchains-1.1.0.xsd">
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>11</version>
    </provides>
    <configuration>
      <jdkHome>/usr/lib/jvm/java-11-openjdk-amd64</jdkHome>
    </configuration>
  </toolchain>
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>25</version>
    </provides>
    <configuration>
      <jdkHome>/usr/lib/jvm/java-11-openjdk-amd64</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOL

# Install project dependencies
mvn -B -ntp -Dtoolchain.skip install -U -DskipTests=true -Drat.skip=true -Dlicense.skip=true -f pom.xml

# Run tests
mvn -B -ntp -P!standard-with-extra-repos -Dtoolchain.skip verify -U -Dmaven.javadoc.skip=true -Dsurefire.toolchain.version=11 -Drat.skip=true -Dlicense.skip=true -f pom.xml

# Print Surefire reports if tests fail
if [ $? -ne 0 ]; then
    ./util/print_surefire_reports.sh
fi