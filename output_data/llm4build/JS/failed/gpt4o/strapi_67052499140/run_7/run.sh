#!/bin/bash

# Determine the base branch for the affected command
BASE_BRANCH=${BASE_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}

# Run tests
yarn nx affected --target=test:front --base=$BASE_BRANCH --head=HEAD --nx-ignore-cycles -- --runInBand --coverage || exit 1