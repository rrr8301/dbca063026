#!/bin/bash

# Run tests
node Makefile mocha

# Run fuzz tests
node Makefile fuzz

# Run EMFILE handling tests
npm run test:emfile