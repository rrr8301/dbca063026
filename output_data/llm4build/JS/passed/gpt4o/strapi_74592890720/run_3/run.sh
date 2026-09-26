#!/bin/bash

# Run monorepo build
yarn nx run-many --targets build --nx-ignore-cycles --skip-nx-cache

# Run tests with the correct target
# Ensure the correct target is specified for the test command
yarn nx run-many --targets test --nx-ignore-cycles --skip-nx-cache -- --coverage