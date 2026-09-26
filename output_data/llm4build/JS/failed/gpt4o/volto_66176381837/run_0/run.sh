#!/bin/bash

# Activate Node.js environment
source ~/.bashrc

# Install Volto dependencies
make install

# Run i18n setup
pnpm --filter @plone/volto i18n

# Run unit tests
pnpm --filter @plone/volto test || true

# Ensure all tests are executed, even if some fail
exit 0