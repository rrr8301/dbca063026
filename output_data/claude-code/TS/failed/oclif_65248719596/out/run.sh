#!/usr/bin/env bash

set -e

export OCLIF_INTEGRATION_MODULE_TYPE=CommonJS
export OCLIF_INTEGRATION_PACKAGE_MANAGER=yarn

cd /app

# Configure git for tests that need to make commits
git config --global user.email "test@example.com"
git config --global user.name "Test User"

yarn test:integration:cli

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
