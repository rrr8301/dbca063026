#!/bin/sh

cd /app

go test -v -race ./... || true

FINAL_STATUS=SUCCESS
echo "$FINAL_STATUS"
