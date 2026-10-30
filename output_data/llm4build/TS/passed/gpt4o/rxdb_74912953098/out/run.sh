#!/bin/bash

# Install project dependencies
npm install || (sleep 15 && npm install) || (sleep 15 && npm install)

# Build the project
npm run build

# Run tests
npm run test:typings
npm run test:react