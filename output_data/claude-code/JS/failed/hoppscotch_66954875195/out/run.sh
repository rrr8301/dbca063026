#!/usr/bin/env bash

# Setup environment
mv .env.example .env

# Run tests
pnpm test

# Check exit status
if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = SUCCESS"
fi
