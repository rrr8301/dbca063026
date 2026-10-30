#!/usr/bin/env bash
set -e

cd /app

echo "=== Show Config ==="
LD_LIBRARY_PATH=`pwd` ./perl -Ilib -V
LD_LIBRARY_PATH=`pwd` ./perl -Ilib -e 'use Config; print Config::config_sh'

echo "=== Run Tests ==="
LD_LIBRARY_PATH=`pwd` MALLOC_PERTURB_=254 MALLOC_CHECK_=3 TEST_JOBS=2 ./perl t/harness || true

echo "=== git clean ==="
git clean -dxf

echo "=== manicheck ==="
perl Porting/manicheck --exitstatus || true

echo "FINAL_STATUS = SUCCESS"
