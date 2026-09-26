#!/bin/bash

set -e

# Build with Maven
mvn -Ddoclint=all --show-version --batch-mode --no-transfer-progress