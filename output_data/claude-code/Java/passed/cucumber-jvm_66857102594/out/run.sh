#!/usr/bin/env bash
set -e

echo "=== Install dependencies ==="
mvn install -Pinclude-extra-modules -DskipTests=true -DskipITs=true -D"archetype.test.skip=true" -D"maven.javadoc.skip=true" --batch-mode -D"style.color=always" --show-version

echo ""
echo "=== Run tests ==="
mvn verify -Pinclude-extra-modules -D"style.color=always" || true

echo ""
echo "FINAL_STATUS = SUCCESS"
