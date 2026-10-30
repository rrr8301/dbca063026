#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Run CI tests for framework
pnpm test:ci