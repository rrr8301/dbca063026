#!/bin/bash

# Run monorepo build
yarn nx run-many --targets build --nx-ignore-cycles --skip-nx-cache

# Run tests with explicit base and head to ensure detection of changes
yarn nx affected --target=test:unit --nx-ignore-cycles --base=main --head=HEAD -- --coverage