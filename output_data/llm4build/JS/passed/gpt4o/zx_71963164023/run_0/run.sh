#!/bin/bash

# Install project dependencies
npm ci

# Run unit tests with coverage
npm run test:coverage || true

# Run type tests
npm run test:types || true