#!/bin/bash

# Clone the repository with submodules
git clone --recurse-submodules https://github.com/your-username/your-repository.git /app
cd /app

# Remove default build config
rm -fv dmlc-core/include/dmlc/build_config_default.h

# Configure the system for sanitizers
if [ "$1" == "sanitizer" ]; then
  export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer
  export ASAN_OPTIONS=symbolize=1
  export UBSAN_OPTIONS=print_stacktrace=1:log_path=ubsan_error.log
  sudo sysctl vm.mmap_rnd_bits=28
fi

# Build and test
bash ops/pipeline/build-cpu.sh cpu-sanitizer