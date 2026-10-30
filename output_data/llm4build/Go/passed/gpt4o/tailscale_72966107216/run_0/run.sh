#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to source directory
cd src

# Install Go dependencies
go mod download

# Build the project
./tool/go build ./...

# Build variant CLIs
./build_dist.sh --extra-small ./cmd/tailscaled
./build_dist.sh --box ./cmd/tailscaled
./build_dist.sh --extra-small --box ./cmd/tailscaled
rm -f tailscaled

# Install qemu-user for tstest/archtest
sudo apt-get -y update
sudo apt-get -y install qemu-user

# Build test wrapper
./tool/go build -o /tmp/testwrapper ./cmd/testwrapper

# Run tests
NOBASHDEBUG=true NOPWSHDEBUG=true PATH=$PWD/tool:$PATH /tmp/testwrapper ./...

# Run benchmarks
./tool/go test -bench=. -benchtime=1x -run=^$ $(for x in $(git grep -l "^func Benchmark" | xargs dirname | sort | uniq); do echo "./$x"; done)

# Check for modified files
git diff --no-ext-diff --name-only --exit-code || (echo "Build/test modified the files above."; exit 1)

# Check for untracked files
if git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*'; then
  echo "Build/test created untracked files in the repo (file names above)."
  exit 1
fi

# Tidy cache
find $(go env GOCACHE) -type f -mmin +90 -delete