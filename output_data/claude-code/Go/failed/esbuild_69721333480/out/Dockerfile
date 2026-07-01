FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    make \
    build-essential \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.26.1
RUN curl -L https://go.dev/dl/go1.26.1.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"
ENV GOROOT="/usr/local/go"

# Install Node.js 18
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Deno 1.40.0
RUN curl -fsSL https://deno.land/install.sh | DENO_INSTALL=/usr/local sh -s v1.40.0 && \
    ln -s /usr/local/bin/deno /usr/bin/deno

# Set working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
