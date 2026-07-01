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

# Resolve vergen_lib version conflict by removing Cargo.lock and updating dependencies
# This ensures all vergen_lib dependencies use compatible versions
RUN rm -f Cargo.lock && \
    cargo update && \
    cargo tree --depth 3 2>&1 | grep -E "vergen|kcl" | head -100 || true

# Copy run.sh and make it executable
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]