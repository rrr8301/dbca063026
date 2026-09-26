#!/bin/bash

# Activate environment (if any specific activation is needed, otherwise skip)

# Install project dependencies
mvn install -Pinclude-extra-modules -DskipTests=true -DskipITs=true -D"archetype.test.skip=true" -D"maven.javadoc.skip=true" --batch-mode -D"style.color=always" --show-version

# Run tests
mvn verify -Pinclude-extra-modules -D"style.color=always" || true

# Ensure all tests are executed, even if some fail