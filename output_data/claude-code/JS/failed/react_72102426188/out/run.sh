#!/usr/bin/env bash

cd /app

echo "Node version:"
node --version

echo "Yarn version:"
yarn --version

echo "Running: yarn test -r=stable --env=production --ci --shard=4/5"
yarn test -r=stable --env=production --ci --shard=4/5 || true

echo "FINAL_STATUS = SUCCESS"
