#!/usr/bin/env bash
set -e

export CI=true

npm test -- --no-parallel

echo "FINAL_STATUS = SUCCESS"
