#!/bin/bash
set -e

npx hereby test
npx hereby test:benchmarks
npx hereby test:tools
npx hereby test:api