#!/bin/bash
set -e
mvn package -pl quarkus/server/,quarkus/dist/ -Drat.skip=true -Dlicense.skip=true -B -nsu