#!/usr/bin/env bash
set -e

mvn --errors --show-version --batch-mode --no-transfer-progress -Ddoclint=all

echo "FINAL_STATUS = SUCCESS"
