FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CGO_ENABLED=1
ENV PATH="/usr/local/go/bin:$PATH"

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.26.0
RUN curl -fsSL "https://golang.org/dl/go1.26.0.linux-$(dpkg --print-architecture).tar.gz" | tar xz -C /usr/local

# Install Node 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

# Install Go dependencies and tscriptify
RUN go mod download

# Install UI dependencies
RUN cd /app/app/ui/app && npm ci

# Install tscriptify
RUN go install github.com/tkrajina/typescriptify-golang-structs/tscriptify@latest

# Copy and run test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
