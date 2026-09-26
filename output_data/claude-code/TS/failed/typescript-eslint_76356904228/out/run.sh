#!/usr/bin/env bash

set -e

export CI=true

pnpm exec nx test eslint-plugin -- --shard=1/4 --coverage

echo "FINAL_STATUS = SUCCESS"
