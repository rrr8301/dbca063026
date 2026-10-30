#!/usr/bin/env bash

set -e

export BUNDLE=true

npm run test -- --no-lint --bundle="$BUNDLE"

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
