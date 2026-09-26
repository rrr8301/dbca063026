#!/bin/bash
set -e

cd /workspace

# Run i18n build step
pnpm --filter @plone/volto i18n

# Run unit tests
pnpm --filter @plone/volto test