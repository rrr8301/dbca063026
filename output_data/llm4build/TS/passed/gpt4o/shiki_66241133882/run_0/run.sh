#!/bin/bash

# Set Node.js version
nvm install 24
nvm use 24

# Install global npm package
npm install -g @antfu/ni

# Install project dependencies
nci

# Build the project
nr build

# Run tests and ensure all tests are executed
nr test --coverage || true