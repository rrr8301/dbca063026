#!/bin/bash
set -e

# Setup pnpm global bin directory
export PNPM_HOME="/root/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
mkdir -p $PNPM_HOME

pnpm install --frozen-lockfile
pnpm buf generate --template buf.ts.gen.yaml
pnpm add -D react-email
pnpm run --filter ./controlplane/emails build
pnpm run --filter ./controlplane/ lint:fix
pnpm run --filter ./controlplane --filter ./connect --filter ./shared --filter ./composition --filter ./protographic build
# Verify dist
pnpm run --filter controlplane test:coverage