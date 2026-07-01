#!/bin/bash
set -e

mvn -V --file pom.xml --no-transfer-progress -DtrimStackTrace=false -Djunit.jupiter.execution.parallel.enabled=false -Dhc.build.toolchain.version="17" -Pdocker -Drat.skip=true -Dlicense.skip=true