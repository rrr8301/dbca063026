FROM node:20-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    echo "America/Los_Angeles" > /etc/timezone

# Install build tools and git
RUN apk add --no-cache \
    git \
    curl \
    build-base \
    python3 \
    make

# Install pnpm globally
RUN npm install -g pnpm

# Create work directory
WORKDIR /workspace

# Copy repository (assumes repo is available in build context)
COPY . .

# Create run script using heredoc (more reliable than printf)
RUN cat > /workspace/run.sh << 'EOF'
#!/bin/sh

set -e

# Print Node and pnpm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "pnpm version: $(pnpm --version)"

# Install dependencies with pnpm (frozen lockfile for reproducibility)
echo "Installing dependencies..."
pnpm install --prod false --frozen-lockfile

# Build cli package
echo "Building cli package..."
cd ./packages/cli
pnpm build
cd ../..

# Build eslint-parser package
echo "Building eslint-parser package..."
cd ./packages/eslint-parser
pnpm build
cd ../..

# Run tests (ensure all tests run even if some fail)
echo "Running tests..."
pnpm test || TEST_FAILED=1

# Exit with appropriate code
if [ "$TEST_FAILED" = "1" ]; then
  echo "Tests failed!"
  exit 1
fi

echo "All tests passed!"
exit 0
EOF
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]