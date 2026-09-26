#!/usr/bin/env bash
set -e

export DEVELOPER=1
export CC=gcc
export CC_PACKAGE=gcc-8
export jobname=linux-TEST-vars
export CI_JOB_IMAGE=ubuntu:20.04
export CUSTOM_PATH=/custom
export TEST_OUTPUT_DIRECTORY=/app/t
export GITHUB_ACTIONS=false
export PATH=/custom:$PATH

# Environment variables for linux-TEST-vars job
export OPENSSL_SHA1_UNSAFE=YesPlease
export GIT_TEST_SPLIT_INDEX=yes
export GIT_TEST_FULL_IN_PACK_ARRAY=true
export GIT_TEST_OE_SIZE=10
export GIT_TEST_OE_DELTA_SIZE=5
export GIT_TEST_COMMIT_GRAPH=1
export GIT_TEST_COMMIT_GRAPH_CHANGED_PATHS=1
export GIT_TEST_MULTI_PACK_INDEX=1
export GIT_TEST_MULTI_PACK_INDEX_WRITE_INCREMENTAL=1
export GIT_TEST_DEFAULT_INITIAL_BRANCH_NAME=master
export GIT_TEST_NO_WRITE_REV_INDEX=1
export GIT_TEST_CHECKOUT_WORKERS=2
export GIT_TEST_PACK_USE_BITMAP_BOUNDARY_TRAVERSAL=1

# Set up environment for python2
export PYTHON_PATH=/usr/bin/python2
export MAKEFLAGS="--jobs=10 CC=gcc PYTHON_PATH=/usr/bin/python2"
export DEFAULT_TEST_TARGET=prove
export GIT_TEST_CLONE_2GB=true
export SKIP_DASHED_BUILT_INS=YesPlease
export GIT_TEST_HTTPD=true
export LINUX_GIT_LFS_VERSION=1.5.2

cd /app

# Run install dependencies
chmod +x ci/install-dependencies.sh
sudo --preserve-env --set-home --user=builder ci/install-dependencies.sh

# Run build and tests
chmod +x ci/run-build-and-tests.sh
sudo --preserve-env --set-home --user=builder ci/run-build-and-tests.sh

echo "FINAL_STATUS = SUCCESS"
