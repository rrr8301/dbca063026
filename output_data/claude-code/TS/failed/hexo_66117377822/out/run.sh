#!/usr/bin/env bash

set -e

export CI=true

echo "Running tests..."
npm test -- --no-parallel

echo "FINAL_STATUS = SUCCESS"
