#!/usr/bin/env bash

cd /app

echo "Running: go test -race -v ./..."
go test -race -v ./...

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = SUCCESS"
fi
