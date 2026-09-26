FROM golang:1.25-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    pkg-config \
    libipmctl5 \
    libipmctl-dev \
    sudo \
    docker.io \
    jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

# Set up git safe directory
RUN git config --global safe.directory /app

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
