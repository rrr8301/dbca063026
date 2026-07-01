FROM golang:1.23-alpine AS go-builder
FROM rust:nightly-2024-12-19-alpine

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apk add --no-cache \
    git \
    wget \
    curl \
    make \
    build-essential \
    pkgconfig \
    openssl-dev \
    python3 \
    py3-pip \
    ca-certificates \
    bash \
    musl-dev \
    gcc

# Copy Go from builder stage
COPY --from=go-builder /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"

# Verify Go installation
RUN go version

# Verify Rust installation
RUN rustc --version && cargo --version

# Create working directory
WORKDIR /workspace

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]