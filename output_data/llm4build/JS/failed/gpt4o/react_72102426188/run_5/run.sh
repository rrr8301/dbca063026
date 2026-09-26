#!/bin/bash

# Activate nvm and use the correct Node.js version
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Ensure clean build directory
rm -rf build

# Run tests
yarn test -r=stable --env=production --ci --shard=4/5