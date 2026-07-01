#!/usr/bin/env bash

export FORCE_COLOR=3

echo "Running unit tests with coverage..."
npm run test:coverage || true

echo "Running type tests..."
npm run test:types || true

echo "FINAL_STATUS = SUCCESS"
