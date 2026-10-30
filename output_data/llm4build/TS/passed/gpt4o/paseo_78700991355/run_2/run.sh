#!/bin/bash

# Activate nvm and use Node.js version 22
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 22

# Run protocol tests
npm run test --workspace=@getpaseo/protocol

# Run client tests
npm run test --workspace=@getpaseo/client

# Typecheck client examples
npm run typecheck:examples --workspace=@getpaseo/client