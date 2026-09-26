#!/bin/bash

# Install project dependencies
npm ci

# Build the app
npm run build --if-present

# Run compress tests
npm run test:compress

# Run mocha tests
TERSER_TEST_ALL=1 npm run test:mocha