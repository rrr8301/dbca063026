#!/bin/bash

# Set environment variables
export BABEL_ENV=test
export BABEL_COVERAGE=true

# Run tests
yarn c8 jest --ci
yarn test:esm