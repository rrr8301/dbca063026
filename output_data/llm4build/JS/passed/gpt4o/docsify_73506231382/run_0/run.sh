#!/bin/bash

# Clone the repository (simulating actions/checkout)
# Assuming the repository is already copied in the Dockerfile

# Build the project
npm run build

# Run unit tests
npm run test:unit -- --ci --runInBand

# Run integration tests
npm run test:integration -- --ci --runInBand

# Run consumption tests
npm run test:consume-types