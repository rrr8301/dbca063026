#!/bin/bash
set -e

# Clone the repository (simulating actions/checkout)
if [ ! -d "capnproto" ]; then
    git clone https://github.com/capnproto/capnproto.git .
fi

# Define the install_deps function from the workflow
install_deps() {
    local clang=$1
    export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install --no-upgrade --no-install-recommends -y clang-$clang libc++-$clang-dev libc++abi-$clang-dev libclang-rt-$clang-dev lld-$clang llvm-$clang
}

# Install dependencies for clang-20
install_deps 20

# Set compiler environment variables
export CC=clang-20
export CXX=clang++-20
export LD=lld-20
export AR=llvm-ar-20

# Run Bazel tests
cd c++ && bazel test --config=ci --config=opt //...