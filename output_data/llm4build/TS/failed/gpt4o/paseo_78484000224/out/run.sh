#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Build app dependencies
npm run build:app-deps

# Run app unit tests
npm run test --workspace=@getpaseo/app