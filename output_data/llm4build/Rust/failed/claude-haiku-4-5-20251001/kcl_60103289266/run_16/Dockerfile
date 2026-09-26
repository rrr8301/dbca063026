FROM golang:1.24-alpine AS go-builder
FROM rust:1.91-alpine

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apk add --no-cache \
    git \
    wget \
    curl \
    make \
    pkgconfig \
    openssl-dev \
    python3 \
    py3-pip \
    ca-certificates \
    bash \
    musl-dev \
    gcc \
    g++ \
    linux-headers

# Copy Go from builder stage
COPY --from=go-builder /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"

# Verify Go installation
RUN go version

# Verify Rust installation
RUN rustc --version && cargo --version

# Install Rust components
RUN rustup component add clippy rustfmt

# Create working directory
WORKDIR /workspace

# Copy entire project source code
COPY . /workspace/

# Resolve vergen_lib version conflict by updating both vergen and vergen_gitcl
# This ensures all vergen_lib dependencies use compatible versions
RUN cargo update -p vergen --aggressive 2>&1 || true && \
    cargo update -p vergen_gitcl --aggressive 2>&1 || true && \
    cargo update -p vergen_lib --aggressive 2>&1 || true

# Resolve dependencies and verify dependency tree
RUN cargo fetch && cargo tree --depth 2 2>&1 | grep -E "vergen|kcl" | head -50

# Copy run.sh and make it executable
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]