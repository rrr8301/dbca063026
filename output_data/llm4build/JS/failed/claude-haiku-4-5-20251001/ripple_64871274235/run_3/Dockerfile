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

# Create and set up run script with proper line endings
RUN printf '#!/bin/bash\n\nset -e\n\n# Print Node and pnpm versions for debugging\necho "Node version: $(node --version)"\necho "npm version: $(npm --version)"\necho "pnpm version: $(pnpm --version)"\n\n# Install dependencies with pnpm (frozen lockfile for reproducibility)\necho "Installing dependencies..."\npnpm install --prod false --frozen-lockfile\n\n# Build cli package\necho "Building cli package..."\ncd ./packages/cli\npnpm build\ncd ../..\n\n# Build eslint-parser package\necho "Building eslint-parser package..."\ncd ./packages/eslint-parser\npnpm build\ncd ../..\n\n# Run tests (ensure all tests run even if some fail)\necho "Running tests..."\npnpm test || TEST_FAILED=1\n\n# Exit with appropriate code\nif [ "$TEST_FAILED" = "1" ]; then\n  echo "Tests failed!"\n  exit 1\nfi\n\necho "All tests passed!"\nexit 0\n' > /workspace/run.sh && \
    chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]