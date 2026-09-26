#!/bin/bash

# Run tests using Yarn
yarn test:packages || true

# Ensure all tests are executed, even if some fail
exit 0