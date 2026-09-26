#!/bin/bash

# Prepare Mimir for Maven 4.x
mkdir -p ~/.mimir
cp .github/ci-mimir-session.properties ~/.mimir/session.properties
cp .github/ci-mimir-daemon.properties ~/.mimir/daemon.properties
mkdir -p ~/.m2
cp .github/ci-extensions.xml ~/.m2/extensions.xml

# Build with Maven
mvn verify -Papache-release -Dgpg.skip=true -e -B -V || true

# Build site with Maven
mvn site -e -B -V -Preporting || true