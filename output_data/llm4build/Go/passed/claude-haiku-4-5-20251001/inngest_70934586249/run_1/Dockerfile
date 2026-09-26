FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set timezone
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*

# Install base dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install Go from official source
RUN mkdir -p /tmp/go-install && \
    cd /tmp/go-install && \
    curl -fsSL https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm -rf /tmp/go-install

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/home/testuser/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git for safe directory and SSH to HTTPS conversion
RUN git config --global --add safe.directory '*' && \
    git config --global url."https://github.com/".insteadOf "git@github.com:"

# Initialize submodules
RUN git submodule update --init --recursive

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace && \
    mkdir -p /home/testuser/go && \
    chown -R testuser:testuser /home/testuser/go

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]