FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and Go 1.26
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.26
RUN curl -fL https://go.dev/dl/go1.26.3.linux-amd64.tar.gz | tar -xz -C /usr/local

ENV PATH="/usr/local/go/bin:${PATH}" \
    GO111MODULE=on

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Verify Go installation
RUN go version

# Run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
