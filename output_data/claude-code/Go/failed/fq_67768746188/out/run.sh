#!/usr/bin/env bash
set -e

export CGO_ENABLED=0
export GOARCH=386

make test

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
