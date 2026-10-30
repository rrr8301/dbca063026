#!/bin/sh
set -e

cd /app

export TSGO_HEREBY_RACE=false
export TSGO_HEREBY_NOEMBED=false
export TSGO_HEREBY_CONCURRENT_TEST_PROGRAMS=false
export TSGO_HEREBY_COVERAGE=true

echo "Running Tests..."
npx hereby test

echo "Running Benchmarks..."
npx hereby test:benchmarks

echo "Running Tools Tests..."
npx hereby test:tools

echo "Running API Tests..."
npx hereby test:api

echo "FINAL_STATUS = SUCCESS"
