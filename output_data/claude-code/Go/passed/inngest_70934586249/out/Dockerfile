FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24.4
RUN wget -q https://go.dev/dl/go1.24.4.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.24.4.linux-amd64.tar.gz && \
    rm go1.24.4.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"

WORKDIR /app

# Copy the entire repository
COPY repo/ /app/

# Create empty website docs directory to satisfy the //go:embed directive
RUN mkdir -p internal/embeddocs/website/pages/docs && \
    touch internal/embeddocs/website/pages/docs/.gitkeep

# Download dependencies
RUN go mod download

# Install the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set environment variables
ENV GOCOVERDIR="coverage"
ENV API_URL="http://127.0.0.1:8288"
ENV INNGEST_EVENT_KEY="test"
ENV INNGEST_SIGNING_KEY="7468697320697320612074657374206b6579"
ENV INNGEST_DEV="http://127.0.0.1:8288"
ENV TEST_MODE="true"
ENV TEST_DATABASE="sqlite"
ENV EXPERIMENTAL_KEY_QUEUES_ENABLE="false"

ENTRYPOINT ["/run.sh"]
