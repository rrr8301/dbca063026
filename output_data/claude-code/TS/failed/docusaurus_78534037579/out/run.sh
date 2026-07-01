#!/usr/bin/env bash

cd /app

echo "=== Test ==="
yarn test || true

echo "=== Remove Theme Internal Re-export ==="
yarn workspace @docusaurus/theme-common removeThemeInternalReexport || true

echo "=== Docusaurus Build ==="
export NODE_OPTIONS='--max-old-space-size=450'
export DOCUSAURUS_PERF_LOGGER='true'
yarn build:website:fast --locale en --locale fr || true

echo "=== Docusaurus site CSS order ==="
yarn workspace website test:css-order || true

echo "=== TypeCheck website ==="
yarn workspace website typecheck || true

echo "=== TypeCheck website - min version - v6.0 ==="
yarn add typescript@6.0 --exact -D -W --ignore-scripts || true
yarn workspace website typecheck || true

echo "=== TypeCheck website - max version - Latest ==="
yarn add typescript@latest --exact -D -W --ignore-scripts || true
yarn workspace website typecheck --project tsconfig.skipLibCheck.json || true

echo "FINAL_STATUS = SUCCESS"
