#!/bin/bash

# Create a Maven toolchains.xml file to specify JDK 25
mkdir -p ~/.m2
cat <<EOL > ~/.m2/toolchains.xml
<?xml version="1.0" encoding="UTF-8"?>
<toolchains xmlns="http://maven.apache.org/TOOLCHAINS/1.1.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/TOOLCHAINS/1.1.0 http://maven.apache.org/xsd/toolchains-1.1.0.xsd">
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>25</version>
      <vendor>oracle</vendor>
    </provides>
    <configuration>
      <jdkHome>/usr/lib/jvm/java-21-openjdk-amd64</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOL

# Install project dependencies
mvn install -DskipTests=true -Dmaven.javadoc.skip=true -Denforcer.skip=true -Dlicense.skip=true -B -V

# Run tests
mvn test -B

# Generate Javadoc
mvn -P '!examples' javadoc:javadoc