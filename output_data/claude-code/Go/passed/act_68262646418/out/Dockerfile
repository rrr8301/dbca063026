FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CGO_ENABLED=0
ENV ACT_OWNER=nektos
ENV ACT_REPOSITORY=nektos/act

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Docker (for QEMU setup and Docker integration)
RUN apt-get update && apt-get install -y \
    docker.io \
    qemu-user-static \
    qemu-system-x86 \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25.0
RUN curl -fsSL https://go.dev/dl/go1.25.0.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

ENV PATH=/usr/local/go/bin:$PATH

WORKDIR /app

COPY repo/ /app/

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
