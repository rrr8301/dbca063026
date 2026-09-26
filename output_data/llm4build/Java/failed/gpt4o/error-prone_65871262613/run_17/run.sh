#!/bin/bash

# Create a Maven toolchains.xml file to specify JDK 21
mkdir -p ~/.m2
cat <<EOL > ~/.m2/toolchains.xml
<?xml version="1.0" encoding="UTF-8"?>
<toolchains xmlns="http://maven.apache.org/TOOLCHAINS/1.1.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/xsd/toolchains-1.1.0.xsd">
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>21</version>
      <vendor>oracle</vendor>
    </provides>
    <configuration>
      <jdkHome>/opt/java/openjdk</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOL

# Ensure Maven uses a repository that might contain the missing artifacts
cat <<EOL > ~/.m2/settings.xml
<settings>
  <profiles>
    <profile>
      <id>custom-repo</id>
      <repositories>
        <repository>
          <id>central</id>
          <url>https://repo.maven.apache.org/maven2</url>
        </repository>
        <!-- Add any additional repositories here -->
      </repositories>
    </profile>
  </profiles>
  <activeProfiles>
    <activeProfile>custom-repo</activeProfile>
  </activeProfiles>
</settings>
EOL

# Install project dependencies
mvn install -Dmaven.javadoc.skip=true -Denforcer.skip=true -Dlicense.skip=true -B -V

# Run tests
mvn test -B

# Generate Javadoc
mvn -P '!examples' javadoc:javadoc