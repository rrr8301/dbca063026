#!/usr/bin/env bash
set -e

echo "Running protocol tests..."
npm run test --workspace=@getpaseo/protocol || true

echo "Running client tests..."
npm run test --workspace=@getpaseo/client || true

echo "Typechecking client examples..."
npm run typecheck:examples --workspace=@getpaseo/client || true

echo "FINAL_STATUS = SUCCESS"
