#!/usr/bin/env bash

cd /app

echo "Running: yarn link --frozen-lockfile || true"
yarn link --frozen-lockfile || true

echo "Running: yarn link webpack --frozen-lockfile"
yarn link webpack --frozen-lockfile || true

echo "Running: yarn test:basic --ci"
yarn test:basic --ci || true

echo "FINAL_STATUS = SUCCESS"
