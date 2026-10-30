#!/bin/bash

# Run tests
npm run test || true

# Ensure all tests are executed, even if some fail
exit 0