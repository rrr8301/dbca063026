#!/bin/bash

# Run tests
yarn test-ci --minWorkers=1 --maxWorkers=$(nproc)