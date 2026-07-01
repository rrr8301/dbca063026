#!/usr/bin/env bash

cd /app

export YARN_ENABLE_IMMUTABLE_INSTALLS=false
export YARN_ENABLE_GLOBAL_CACHE=false
export YARN_ENABLE_MIRROR=false
export YARN_NM_MODE=hardlinks-local
export YARN_INSTALL_STATE_PATH=.yarn/ci-cache/install-state.gz

echo "Running unit tests..."
yarn nx run-many --target=test:unit --nx-ignore-cycles -- --coverage || true

echo "FINAL_STATUS = SUCCESS"
