#!/bin/bash

# Activate nvm and use the correct Node.js version
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use $(cat /path/to/vuetify/.nvmrc)

# Navigate to the working directory
cd /app/packages/vuetify

# Install project dependencies
pnpm install

# Run tests
pnpm run test