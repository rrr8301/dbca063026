#!/bin/bash

# Activate environment variables
export FORCE_COLOR=3
export npm_config_audit=false
export npm_config_fund=false
export npm_config_save=false
export npm_config_package_lock=false

# Simulate downloading or building the artifact
# Placeholder: Assume the build artifact is present or can be built

# Install project dependencies
npm ci

# Run unit tests and ensure all tests are executed
npm run test:coverage || true

# Run type tests and ensure all tests are executed
npm run test:types || true