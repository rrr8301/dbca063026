#!/usr/bin/env bash

cd /app

echo "Starting closure-compiler tests..."
unset ANDROID_HOME
bazelisk test //:all

echo "FINAL_STATUS = SUCCESS"
