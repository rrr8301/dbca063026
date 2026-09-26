#!/bin/bash

# Install project dependencies
npm ci

# Build app dependencies
npm run build:app-deps

# Run app unit tests
npm run test --workspace=@getpaseo/app