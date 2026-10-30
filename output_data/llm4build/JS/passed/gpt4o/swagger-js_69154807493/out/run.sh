#!/bin/bash

# Run linting
npm run lint

# Run tests
npm test || true

# Build the project
npm run build