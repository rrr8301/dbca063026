#!/bin/bash

# Ensure the script is executable
chmod +x run.sh

# Build app dependencies
npm run build:app-deps

# Run app unit tests
npm run test --workspace=@getpaseo/app