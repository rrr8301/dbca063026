#!/bin/bash

set -e

# Update /etc/hosts to avoid DNS resolution issues
echo "Updating /etc/hosts..."
if [ -f .github/actions/update-hosts/hosts ]; then
  printf "\n\n$(cat .github/actions/update-hosts/hosts)" | sudo tee -a /etc/hosts > /dev/null
fi

# Extract Node.js and PNPM versions from js/pom.xml
echo "Extracting Node.js and PNPM versions..."
NODE_VERSION=$(grep '<node.version>' js/pom.xml | cut -d '>' -f 2 | cut -d '<' -f 1 | cut -c 2-)
PNPM_VERSION=$(grep '<pnpm.version>' js/pom.xml | cut -d '>' -f 2 | cut -d '<' -f 1 | cut -c 1-)

echo "Node.js version: $NODE_VERSION"
echo "PNPM version: $PNPM_VERSION"

# Download Node.js and PNPM if not already cached
echo "Downloading Node.js and PNPM tooling..."
./.github/scripts/download-node-tooling.sh "$NODE_VERSION" "$PNPM_VERSION" || true

# Extract Maven artifacts cache if available
echo "Extracting Maven artifacts cache..."
if [ -f m2-keycloak.tzts ]; then
  tar -C ~/ --use-compress-program="zstd -d" -xf m2-keycloak.tzts || true
fi

# Set Maven arguments from environment
export MAVEN_ARGS="-B -nsu -Daether.connector.http.connectionMaxTtl=25"
export SUREFIRE_RETRY="-Dsurefire.rerunFailingTestsCount=2"

# Build keycloak-quarkus-dist
echo "Building keycloak-quarkus-dist..."
./mvnw package -pl quarkus/server/,quarkus/dist/ $MAVEN_ARGS

# Run Base1TestSuite tests
echo "Running Base1TestSuite tests..."
./mvnw package -f tests/pom.xml -Dtest=Base1TestSuite $MAVEN_ARGS $SUREFIRE_RETRY

echo "Tests completed successfully!"