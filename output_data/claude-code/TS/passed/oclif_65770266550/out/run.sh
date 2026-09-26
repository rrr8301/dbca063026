#!/usr/bin/env bash

set -e

cd /app

# Run the unit tests (this will also trigger posttest which runs lint)
yarn test

# If we got here, tests passed
echo "FINAL_STATUS = SUCCESS"
