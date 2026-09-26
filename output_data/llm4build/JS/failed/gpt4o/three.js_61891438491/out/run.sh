#!/bin/bash

# Run lint tests
npm run lint || true

# Run unit tests
npm run test-unit || true

# Run unit addons tests
npm run test-unit-addons || true

# Run end-to-end tests with coverage
npm run test-e2e-cov || true