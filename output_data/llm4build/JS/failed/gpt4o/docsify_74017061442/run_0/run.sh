#!/bin/bash

# Build the project
npm run build

# Run unit tests
npm run test:unit -- --ci --runInBand

# Run integration tests
npm run test:integration -- --ci --runInBand