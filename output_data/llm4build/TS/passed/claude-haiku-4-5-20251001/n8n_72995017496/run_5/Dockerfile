FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.14.1
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Verify Node.js installation
RUN node --version && npm --version

# Install pnpm globally
RUN npm install -g pnpm@latest

# Verify pnpm installation
RUN pnpm --version

# Set Node.js memory option
ENV NODE_OPTIONS=--max-old-space-size=7168

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Create run script
RUN cat > /workspace/run.sh << 'SCRIPT_EOF'
#!/bin/bash

set -e

# Track test results
BACKEND_UNIT_RESULT=0
BACKEND_INTEGRATION_RESULT=0
NODES_UNIT_RESULT=0
FRONTEND_SHARD1_RESULT=0
FRONTEND_SHARD2_RESULT=0

echo "=========================================="
echo "n8n Unit Tests - Local Build"
echo "=========================================="

# Install dependencies
echo ""
echo "Installing dependencies..."
pnpm install --frozen-lockfile

# Build project
echo ""
echo "Building project..."
pnpm build --summarize

# Backend Unit Tests
echo ""
echo "=========================================="
echo "Running Backend Unit Tests..."
echo "=========================================="
pnpm test:ci:backend:unit --summarize || BACKEND_UNIT_RESULT=$?
if [ $BACKEND_UNIT_RESULT -ne 0 ]; then
    echo "❌ Backend Unit Tests FAILED"
else
    echo "✅ Backend Unit Tests PASSED"
fi

# Backend Integration Tests
echo ""
echo "=========================================="
echo "Running Backend Integration Tests..."
echo "=========================================="
pnpm test:ci:backend:integration --summarize || BACKEND_INTEGRATION_RESULT=$?
if [ $BACKEND_INTEGRATION_RESULT -ne 0 ]; then
    echo "❌ Backend Integration Tests FAILED"
else
    echo "✅ Backend Integration Tests PASSED"
fi

# Nodes Unit Tests
echo ""
echo "=========================================="
echo "Running Nodes Unit Tests..."
echo "=========================================="
pnpm turbo test --filter=n8n-nodes-base --summarize || NODES_UNIT_RESULT=$?
if [ $NODES_UNIT_RESULT -ne 0 ]; then
    echo "❌ Nodes Unit Tests FAILED"
else
    echo "✅ Nodes Unit Tests PASSED"
fi

# Frontend Unit Tests - Shard 1/2
echo ""
echo "=========================================="
echo "Running Frontend Unit Tests (Shard 1/2)..."
echo "=========================================="
VITEST_SHARD=1/2 pnpm test:ci:frontend --summarize -- --shard=1/2 || FRONTEND_SHARD1_RESULT=$?
if [ $FRONTEND_SHARD1_RESULT -ne 0 ]; then
    echo "❌ Frontend Unit Tests (Shard 1/2) FAILED"
else
    echo "✅ Frontend Unit Tests (Shard 1/2) PASSED"
fi

# Frontend Unit Tests - Shard 2/2
echo ""
echo "=========================================="
echo "Running Frontend Unit Tests (Shard 2/2)..."
echo "=========================================="
VITEST_SHARD=2/2 pnpm test:ci:frontend --summarize -- --shard=2/2 || FRONTEND_SHARD2_RESULT=$?
if [ $FRONTEND_SHARD2_RESULT -ne 0 ]; then
    echo "❌ Frontend Unit Tests (Shard 2/2) FAILED"
else
    echo "✅ Frontend Unit Tests (Shard 2/2) PASSED"
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Backend Unit Tests:        $([ $BACKEND_UNIT_RESULT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "Backend Integration Tests: $([ $BACKEND_INTEGRATION_RESULT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "Nodes Unit Tests:          $([ $NODES_UNIT_RESULT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "Frontend Tests (Shard 1/2): $([ $FRONTEND_SHARD1_RESULT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "Frontend Tests (Shard 2/2): $([ $FRONTEND_SHARD2_RESULT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "=========================================="

# Determine overall exit code
OVERALL_RESULT=0
if [ $BACKEND_UNIT_RESULT -ne 0 ] || \
   [ $BACKEND_INTEGRATION_RESULT -ne 0 ] || \
   [ $NODES_UNIT_RESULT -ne 0 ] || \
   [ $FRONTEND_SHARD1_RESULT -ne 0 ] || \
   [ $FRONTEND_SHARD2_RESULT -ne 0 ]; then
    OVERALL_RESULT=1
    echo "❌ Some tests FAILED"
else
    echo "✅ All tests PASSED"
fi

exit $OVERALL_RESULT
SCRIPT_EOF
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]