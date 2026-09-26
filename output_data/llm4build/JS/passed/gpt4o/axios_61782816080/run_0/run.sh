#!/bin/bash

# Install project dependencies
npm ci

# Build the project
npm run build

# Run unit tests
npm run test:node || true

# Run package tests
npm run test:package || true