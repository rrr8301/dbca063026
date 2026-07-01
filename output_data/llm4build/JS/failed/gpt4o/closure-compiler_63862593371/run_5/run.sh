#!/bin/bash

# Unset ANDROID_HOME if set
unset ANDROID_HOME

# Run Bazel tests
bazelisk test //:all