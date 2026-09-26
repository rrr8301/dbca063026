FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get -y update && apt-get -y install \
    git \
    build-essential \
    curl \
    wget \
    qemu-user \
    make \
    bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go (latest stable)
RUN curl -fsSL https://go.dev/dl/go1.23.0.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"
ENV GOMODCACHE="/workspace/gomodcache"
ENV CMD_GO_USE_GIT_HASH="true"
ENV GOARCH="amd64"

# Create workspace
WORKDIR /workspace

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]