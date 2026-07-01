#!/bin/bash

set -e

# Activate Node.js environment
. ~/.nvm/nvm.sh
nvm use

# Install project dependencies
npm ci

# Run tests
set +e
./scripts/test.sh --tfs "Unit Tests"
npm run test-node
npm run test-browser-no-install -- --browser chromium --tfs "Browser Unit Tests"
npm run gulp transpile-client-esbuild transpile-extensions
npm run gulp compile-extension:configuration-editing compile-extension:css-language-features-server compile-extension:emmet compile-extension:git compile-extension:github-authentication compile-extension:html-language-features-server compile-extension:ipynb compile-extension:notebook-renderers compile-extension:json-language-features-server compile-extension:markdown-language-features compile-extension-media compile-extension:microsoft-authentication compile-extension:typescript-language-features compile-extension:vscode-api-tests compile-extension:vscode-colorize-tests compile-extension:vscode-colorize-perf-tests compile-extension:vscode-test-resolver
npm --prefix extensions/copilot run compile
./scripts/test-integration.sh --tfs "Integration Tests"
npm run test-web-integration.sh --browser chromium
npm run smoketest-no-compile -- --tracing
npm run smoketest-no-compile -- --web --tracing --headless
npm run smoketest-no-compile -- --remote --tracing
set -e