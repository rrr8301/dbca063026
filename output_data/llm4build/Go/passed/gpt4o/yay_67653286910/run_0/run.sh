#!/bin/bash

# Lint the code
export GOFLAGS="-buildvcs=false -tags=next"
/app/bin/golangci-lint run -v ./...

# Run build and tests
make test

# Run integration tests
useradd -m yay
chown -R yay:yay .
cp -r ~/go/ /home/yay/go/
chown -R yay:yay /home/yay/go/
su yay -c "make test-integration" || true

# Build yay artifact
export GOFLAGS="-buildvcs=false -tags=next"
make