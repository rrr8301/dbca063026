#!/usr/bin/env bash
set -e

# Source nvm to get access to npm and node
. /root/.nvm/nvm.sh
nvm use 25

# Run ls-engines
npx ls-engines

# Run unit tests
npm run unit-test

# If we reach here, tests passed
FINAL_STATUS=SUCCESS
echo "FINAL_STATUS=$FINAL_STATUS"
