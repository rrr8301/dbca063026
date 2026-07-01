#!/bin/bash

# Set environment variables
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"
export SKIP_DOCKER_IMAGE_INSTALL="true"
export CI=true
export SALTCORN_MULTI_TENANT=true
export SALTCORN_SESSION_SECRET="rehjtyjrtjr"
export SALTCORN_JWT_SECRET="2f75ade09981d68f366a4e577025440d10b735cc270fc2092077140f98a41dab331589c79364601150816d9a3c6f34abf881019e2097e21a24963c56b9135bbb"
export SALTCORN_NWORKERS=1
export PUPPETEER_CHROMIUM_BIN="/usr/bin/google-chrome"
export PGHOST=localhost
export PGUSER=postgres
export PGPASSWORD=postgres
export NODE_OPTIONS="--max-old-space-size=4096"

# Install npm dependencies
npm install --legacy-peer-deps

# Run TypeScript compiler
npm run tsc

# Modify /etc/hosts
echo '127.0.0.1 example.com sub.example.com sub1.example.com sub2.example.com sub3.example.com sub4.example.com sub5.example.com' | sudo tee -a /etc/hosts
echo '127.0.0.1 otherexample.com' | sudo tee -a /etc/hosts

# Run tests
packages/saltcorn-cli/bin/saltcorn run-tests
packages/saltcorn-cli/bin/saltcorn run-tests saltcorn-data
packages/saltcorn-cli/bin/saltcorn run-tests server
packages/saltcorn-cli/bin/saltcorn run-tests view-queries