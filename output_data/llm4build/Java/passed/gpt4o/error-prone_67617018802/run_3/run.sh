#!/bin/bash

# Activate environment
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Create Maven toolchains.xml
mkdir -p ~/.m2
cat <<EOL > ~/.m2/toolchains.xml
<?xml version="1.0" encoding="UTF-8"?>
<toolchains xmlns="http://maven.apache.org/TOOLCHAINS/1.1.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/TOOLCHAINS/1.1.0 http://maven.apache.org/xsd/toolchains-1.1.0.xsd">
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>21</version>
      <vendor>sun</vendor>
    </provides>
    <configuration>
      <jdkHome>/usr/lib/jvm/java-21-openjdk-amd64</jdkHome>
    </configuration>
  </toolchain>
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>25</version>
      <vendor>sun</vendor>
    </provides>
    <configuration>
      <jdkHome>/usr/lib/jvm/java-25-openjdk-amd64</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOL

# Install project dependencies
mvn install -DskipTests=true -Dmaven.javadoc.skip=true -B -V -Drat.skip=true -Dlicense.skip=true

# Run tests
mvn test -B -Drat.skip=true -Dlicense.skip=true

# Generate Javadoc
mvn -P '!examples' javadoc:javadoc -Drat.skip=true -Dlicense.skip=true