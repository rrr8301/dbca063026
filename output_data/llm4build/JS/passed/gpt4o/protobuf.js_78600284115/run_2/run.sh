#!/bin/bash

# Install project dependencies
npm install

# Run tests
npm run test:sources
npm run test:types