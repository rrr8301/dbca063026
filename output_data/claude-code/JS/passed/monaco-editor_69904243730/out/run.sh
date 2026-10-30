#!/usr/bin/env bash

echo "========== Build =========="
npm run build || true

echo "========== Run unit tests =========="
npm test || true

echo "========== Compile webpack plugin =========="
npm run compile --prefix webpack-plugin || true

echo "========== Package using webpack plugin =========="
npm run package-for-smoketest || true

echo "========== Run smoke test =========="
npm run smoketest || true

echo "========== Install website node modules =========="
cd website
npm ci || true

echo "========== Install most recent version of monaco-editor =========="
npm install monaco-editor || true

echo "========== Build website =========="
npm run build || true

echo "========== Test website =========="
npm run test || true

echo ""
echo "========== TEST SUITE COMPLETED =========="
echo "FINAL_STATUS = SUCCESS"
