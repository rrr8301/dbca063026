#!/bin/bash

set -e

# Install npm dependencies
npm ci

# Run the selector-native tests
npm run test:selector-native