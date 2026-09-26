FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    make \
    gcc \
    g++ \
    tzdata \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install Go
RUN curl -sSL https://golang.org/dl/go1.26.0.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Install go-test-json-to-loki
RUN go install calmh.dev/go-test-json-to-loki@latest

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]