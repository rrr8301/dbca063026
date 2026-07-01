#!/usr/bin/env bash
set -e

npm run test --workspace=@getpaseo/app

echo "FINAL_STATUS = SUCCESS"
