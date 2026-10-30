#!/bin/bash

# Run build
pnpm exec nx run-many --target=build --parallel --exclude=website --exclude=website-eslint

# Run unit tests with coverage for eslint-plugin
pnpm exec nx test eslint-plugin -- --shard=1/4 --coverage