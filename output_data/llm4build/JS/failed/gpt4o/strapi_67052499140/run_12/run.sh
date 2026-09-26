#!/bin/bash

# Check if the .git directory exists
if [ -d .git ]; then
  # Determine the base branch for the affected command
  BASE_BRANCH=${BASE_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}
else
  # Default to main if .git is not available
  BASE_BRANCH="main"
fi

# Run tests
yarn nx affected --target=test:front --base=$BASE_BRANCH --head=HEAD --nx-ignore-cycles -- --runInBand --coverage || exit 1