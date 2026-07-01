FROM ubuntu:22.04

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    make \
    softhsm2 \
    opensc \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go (latest or from go.mod)
RUN curl -fsSL https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/root/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Set HSM environment variables
ENV HSM_ENABLED=true
ENV HSM_LIBRARY=/usr/lib/softhsm/libsofthsm2.so
ENV HSM_TOKEN_LABEL=hydra
ENV HSM_PIN=1234

# Create and setup HSM token directory
RUN mkdir -p /var/lib/softhsm/tokens && \
    chmod -R a+rwx /var/lib/softhsm && \
    chmod a+rx /etc/softhsm && \
    chmod a+r /etc/softhsm/*

# Set working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]