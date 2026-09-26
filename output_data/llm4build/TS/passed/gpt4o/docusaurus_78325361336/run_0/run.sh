#!/bin/bash

# Activate nvm and use Node.js 26
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 26

# Install project dependencies
yarn install --frozen-lockfile || yarn install --frozen-lockfile || yarn install --frozen-lockfile

# Run tests
yarn test

# Remove theme internal re-export
yarn workspace @docusaurus/theme-common removeThemeInternalReexport

# Build the Docusaurus website
NODE_OPTIONS='--max-old-space-size=450' DOCUSAURUS_PERF_LOGGER='true' yarn build:website:fast --locale en --locale fr

# Test CSS order
yarn workspace website test:css-order

# Typecheck website
yarn workspace website typecheck

# Typecheck website with TypeScript 6.0
yarn add typescript@6.0 --exact -D -W --ignore-scripts
yarn workspace website typecheck

# Typecheck website with latest TypeScript
yarn add typescript@latest --exact -D -W --ignore-scripts
yarn workspace website typecheck --project tsconfig.skipLibCheck.json