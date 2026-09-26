#!/bin/bash

# Run monorepo build
yarn nx run-many --targets build --nx-ignore-cycles --skip-nx-cache

# Run tests
yarn nx affected --target=test:unit --nx-ignore-cycles -- --coverage