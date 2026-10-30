#!/bin/bash

# Activate nvm and use the specified Node.js version
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use $(cat /app/react-navigation/.nvmrc)

# Install project dependencies
yarn install --immutable

# Run unit tests
yarn test --maxWorkers=2 --coverage