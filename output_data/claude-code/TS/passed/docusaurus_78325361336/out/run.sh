#!/usr/bin/env bash
set -e

cd /app

echo "========== Installation =========="
yarn install --frozen-lockfile || yarn install --frozen-lockfile || yarn install --frozen-lockfile

echo "========== Test =========="
yarn test

echo "========== Remove Theme Internal Re-export =========="
yarn workspace @docusaurus/theme-common removeThemeInternalReexport

echo "========== Docusaurus Build =========="
export NODE_OPTIONS='--max-old-space-size=450'
export DOCUSAURUS_PERF_LOGGER='true'
yarn build:website:fast --locale en --locale fr

echo "========== Docusaurus site CSS order =========="
yarn workspace website test:css-order

echo "========== TypeCheck website =========="
yarn workspace website typecheck

echo "========== TypeCheck website - min version - v6.0 =========="
yarn add typescript@6.0 --exact -D -W --ignore-scripts
yarn workspace website typecheck

echo "========== TypeCheck website - max version - Latest =========="
yarn add typescript@latest --exact -D -W --ignore-scripts
yarn workspace website typecheck --project tsconfig.skipLibCheck.json

echo "FINAL_STATUS = SUCCESS"
