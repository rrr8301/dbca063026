#!/bin/bash

# Run monorepo build
yarn nx run-many --targets build --nx-ignore-cycles --skip-nx-cache

# Run tests with explicit base and head to ensure detection of changes
# Ensure the correct target is specified for the test command
yarn nx affected --target=test --nx-ignore-cycles --base=main --head=HEAD -- --coverage