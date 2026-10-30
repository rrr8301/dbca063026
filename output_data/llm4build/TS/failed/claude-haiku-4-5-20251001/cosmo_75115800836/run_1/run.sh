#!/bin/bash
set -e

pnpm install --frozen-lockfile
pnpm buf generate --template buf.ts.gen.yaml
pnpm add -g react-email
pnpm run --filter ./controlplane/emails build
pnpm run --filter ./controlplane/ lint:fix
pnpm run --filter ./controlplane --filter ./connect --filter ./shared --filter ./composition --filter ./protographic build
# Verify dist
pnpm run --filter controlplane test:coverage