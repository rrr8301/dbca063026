#!/bin/bash

# Build with Maven
mvn --errors --show-version --batch-mode --no-transfer-progress -Ddoclint=all -Drat.skip=true -Dlicense.skip=true clean install