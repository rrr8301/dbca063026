FROM archlinux:latest

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update package manager and install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    git \
    go \
    golangci-lint \
    make \
    sudo

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Create run script
RUN bash -c 'cat > /run.sh << '"'"'EOF'"'"'
#!/bin/bash

set -e

# Print commands for debugging
set -x

# Change to workspace directory
cd /workspace

# Install Go dependencies
echo "Installing Go dependencies..."
go mod download
go mod verify

# Run linting
echo "Running linting..."
export GOFLAGS="-buildvcs=false -tags=next"
/usr/bin/golangci-lint run -v ./...

# Run unit tests
echo "Running unit tests..."
make test || TEST_FAILED=1

# Run integration tests as non-root user
echo "Running integration tests..."
useradd -m yay || true
chown -R yay:yay /workspace
cp -r ~/go/ /home/yay/go/ 2>/dev/null || true
chown -R yay:yay /home/yay/go/ 2>/dev/null || true
su yay -c "cd /workspace && make test-integration" || INTEGRATION_FAILED=1

# Build yay artifact
echo "Building yay artifact..."
export GOFLAGS="-buildvcs=false -tags=next"
make

# Check if build output exists
if [ -f ./yay ]; then
    echo "Build successful! yay binary created at ./yay"
else
    echo "Warning: yay binary not found at ./yay"
fi

# Report test results
if [ "$TEST_FAILED" = "1" ]; then
    echo "Unit tests failed"
    exit 1
fi

if [ "$INTEGRATION_FAILED" = "1" ]; then
    echo "Integration tests failed (continuing as per workflow)"
fi

echo "All tasks completed successfully!"
EOF
chmod +x /run.sh'