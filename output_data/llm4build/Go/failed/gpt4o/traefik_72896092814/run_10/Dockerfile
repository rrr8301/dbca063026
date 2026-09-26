FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget

# Install Go
COPY .go-version /tmp/.go-version
RUN if [ ! -f /tmp/.go-version ]; then echo ".go-version file not found"; exit 1; fi && \
    GO_VERSION=$(cat /tmp/.go-version) && \
    if [ -z "$GO_VERSION" ]; then echo "Go version not specified"; exit 1; fi && \
    curl -sSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o /tmp/go${GO_VERSION}.linux-amd64.tar.gz && \
    if ! tar -C /usr/local -xzf /tmp/go${GO_VERSION}.linux-amd64.tar.gz; then \
        echo "Failed to extract Go tarball"; exit 1; \
    fi && \
    rm /tmp/go${GO_VERSION}.linux-amd64.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]