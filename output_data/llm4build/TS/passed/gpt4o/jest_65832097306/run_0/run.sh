#!/bin/bash

# Get number of CPU cores
CPU_CORES=$(nproc)

# Run tests with coverage
yarn jest-coverage --color --config jest.config.ci.mjs --max-workers $CPU_CORES --shard=3/4 || true

# Map coverage
node ./scripts/mapCoverage.mjs || true