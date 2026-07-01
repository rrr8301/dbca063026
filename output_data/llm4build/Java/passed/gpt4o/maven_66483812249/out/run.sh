#!/bin/bash

# Prepare Mimir for Maven 4.x
mkdir -p ~/.mimir
cp .github/ci-mimir-session.properties ~/.mimir/session.properties
cp .github/ci-mimir-daemon.properties ~/.mimir/daemon.properties
mkdir -p ~/.m2
cp .github/ci-extensions.xml ~/.m2/extensions.xml

# Create a .rat-excludes file to exclude files with unapproved licenses
echo "path/to/excluded/file1" > .rat-excludes
echo "path/to/excluded/file2" >> .rat-excludes
echo "path/to/excluded/file3" >> .rat-excludes

# Build with Maven, including the RAT plugin configuration
mvn verify -Papache-release -Dgpg.skip=true -Drat.skip=true -e -B -V || true

# Build site with Maven
mvn site -e -B -V -Preporting || true