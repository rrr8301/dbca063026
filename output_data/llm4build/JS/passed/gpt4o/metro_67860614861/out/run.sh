#!/bin/bash

# Activate environment (if any specific activation is needed, otherwise skip)

# Install project dependencies
yarn install --no-lockfile --non-interactive --ignore-scripts

# Run Jest tests with retries
max_attempts=3
attempt=1
until yarn jest --ci --maxWorkers 4 --reporters=default --reporters=jest-junit --rootdir='./'; do
  if [ $attempt -ge $max_attempts ]; then
    echo "Tests failed after $max_attempts attempts"
    exit 1
  fi
  echo "Attempt $attempt failed, retrying..."
  attempt=$((attempt + 1))
  sleep 5
done