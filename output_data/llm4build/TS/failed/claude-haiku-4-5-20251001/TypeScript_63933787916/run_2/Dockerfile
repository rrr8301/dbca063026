FROM node:14-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    echo "America/Los_Angeles" > /etc/timezone

# Install build tools and git
RUN apk add --no-cache \
    git \
    gcc \
    musl-dev \
    python3 \
    make \
    g++ \
    curl

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install project dependencies
RUN npm ci

# Create run.sh script directly in the container
RUN cat > /workspace/run.sh << 'EOF'
#!/bin/bash

set -e

# Track test failures but continue execution
TEST_FAILED=0

echo "=== Running TypeScript Tests ==="
npm run test -- --no-lint --bundle=true || TEST_FAILED=1

# On test failure, run baseline acceptance and check diff
if [ $TEST_FAILED -eq 1 ]; then
    echo "=== Tests failed, checking baseline diff ==="
    npx hereby baseline-accept || true
    git add tests/baselines/reference || true
    git diff --staged --exit-code || true
fi

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "=== Test suite failed ==="
    exit 1
fi

echo "=== All tests passed ==="
exit 0
EOF

RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]