#!/bin/bash

# Run npm tests with coverage
mkdir -p /app/superset-frontend/coverage
npm run test -- --coverage --shard=4/8 --coverageReporters=json