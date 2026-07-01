#!/bin/bash
set -e

# Run tests with coverage
MUTE_REACT_ACT_WARNINGS=1 pnpm test -- --coverage

echo "Tests completed successfully"