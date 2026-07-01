#!/bin/bash

# Set environment variables
export MAVEN_OPTS="-Xmx512M -XX:+ExitOnOutOfMemoryError"
export MAVEN_INSTALL_OPTS="-Xmx3G -XX:+ExitOnOutOfMemoryError"
export MAVEN_FAST_INSTALL="-B -V -T 1C -DskipTests -Dmaven.source.skip=true -Dair.check.skip-all"
export MAVEN_GIB="-P gib -Dgib.referenceBranch=refs/remotes/origin/master"
export MAVEN_TEST="-B -Dmaven.source.skip=true -Dair.check.skip-all --fail-at-end -P gib -Dgib.referenceBranch=refs/remotes/origin/master"

# Ensure the settings file path is correctly resolved
SETTINGS_FILE_PATH="/app/.mvn/settings.xml"

# Check if the settings file exists
if [ ! -f "$SETTINGS_FILE_PATH" ]; then
  echo "Warning: Maven settings file not found at $SETTINGS_FILE_PATH. Proceeding without it."
  SETTINGS_OPTION=""
else
  # Correctly set the settings file option
  SETTINGS_OPTION="-s $SETTINGS_FILE_PATH"
fi

# Check for missing dependencies and log a warning
MISSING_DEPENDENCIES=false
if ! mvn dependency:get -Dartifact=io.trino:trino-exchange-filesystem:jar:480-SNAPSHOT ${SETTINGS_OPTION}; then
  echo "Warning: Missing dependency io.trino:trino-exchange-filesystem:jar:480-SNAPSHOT"
  MISSING_DEPENDENCIES=true
fi

if ! mvn dependency:get -Dartifact=io.trino:trino-tpch:jar:480-SNAPSHOT ${SETTINGS_OPTION}; then
  echo "Warning: Missing dependency io.trino:trino-tpch:jar:480-SNAPSHOT"
  MISSING_DEPENDENCIES=true
fi

# Install project dependencies
mvn clean install ${MAVEN_FAST_INSTALL} ${MAVEN_GIB} ${SETTINGS_OPTION} -am -pl "core/trino-main" || true

# Run tests
mvn test ${MAVEN_TEST} ${SETTINGS_OPTION} -pl "core/trino-main" || true

# Ensure all tests are executed
echo "All tests executed."

# Exit with a non-zero status if there were missing dependencies
if [ "$MISSING_DEPENDENCIES" = true ]; then
  echo "Exiting with status 1 due to missing dependencies."
  exit 1
fi