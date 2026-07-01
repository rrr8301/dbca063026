#!/bin/bash
set -e

# Install dependencies (without running scripts, as per workflow)
npm install --ignore-scripts

# Run unit tests
npm run unit