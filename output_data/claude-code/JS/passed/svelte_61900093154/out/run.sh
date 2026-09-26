#!/usr/bin/env bash

set -e

export CI=true

echo "Running pnpm test..."
pnpm test

echo "FINAL_STATUS = SUCCESS"
