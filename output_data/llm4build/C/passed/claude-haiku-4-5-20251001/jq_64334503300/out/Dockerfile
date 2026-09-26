FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    automake \
    autoconf \
    libtool \
    crossbuild-essential-amd64 \
    make \
    gcc \
    g++ \
    file \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository (assumes it's available on host)
COPY . .

# Fix git ownership issues in container
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace

# Make run.sh executable
RUN chmod +x /workspace/run.sh

# Switch to non-root user
USER testuser

# Set job environment variables
ENV AR=x86_64-linux-gnu-ar \
    CHOST=x86_64-linux-gnu \
    CC=x86_64-linux-gnu-gcc \
    CPP=x86_64-linux-gnu-cpp \
    LDFLAGS=-s \
    SUFFIX=linux-amd64

ENTRYPOINT ["/workspace/run.sh"]