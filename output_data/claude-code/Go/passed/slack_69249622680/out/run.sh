#!/usr/bin/env bash

cd /app

if go test -v -race ./...; then
  FINAL_STATUS=SUCCESS
else
  FINAL_STATUS=FAIL
fi

echo "FINAL_STATUS = $FINAL_STATUS"
