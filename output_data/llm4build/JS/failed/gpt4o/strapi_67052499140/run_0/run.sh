#!/bin/bash

# Run tests
yarn nx affected --target=test:front --nx-ignore-cycles -- --runInBand --coverage