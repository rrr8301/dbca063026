FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Set CI environment
ENV CI=true \
    GITHUB_ACTIONS=true

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    gcc \
    g++ \
    make \
    pkg-config \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.26.0
ENV GO_VERSION=1.26.0 \
    GOPATH=/home/testuser/go \
    PATH=/usr/local/go/bin:/home/testuser/go/bin:$PATH

RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o /tmp/go.tar.gz \
    && tar -C /usr/local -xzf /tmp/go.tar.gz \
    && rm /tmp/go.tar.gz \
    && go version

# Set build environment variables
ENV GO_VERSION="~1.26.0" \
    GOMIPS=softfloat \
    GOARM="6" \
    LOGGER_DISCARD="1" \
    BUILD_USER=builder \
    BUILD_HOST=github.syncthing.net \
    TAGS="sqlite_omit_load_extension sqlite_dbstat" \
    TAGS_LINUX="sqlite_omit_load_extension sqlite_dbstat netgo osusergo"

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace /home/testuser

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]