FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    curl \
    wget \
    sudo \
    postgresql \
    mysql-server

# Install Go
RUN wget https://golang.org/dl/go1.26.2.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.26.2.linux-amd64.tar.gz && \
    rm go1.26.2.linux-amd64.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:/home/appuser/go/bin:${PATH}"

# Create a non-root user
RUN useradd -m -s /bin/bash appuser && echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to non-root user
USER appuser

# Create work directory
WORKDIR /app

# Copy repository
COPY --chown=appuser:appuser . .

# Install Go dependencies
RUN go install gotest.tools/gotestsum@latest && \
    go install github.com/sqlc-dev/sqlc-gen-test@v0.1.0 && \
    go install ./scripts/test-json-process-plugin/ && \
    CGO_ENABLED=0 go install ./...

# Copy run.sh and make it executable
COPY --chown=appuser:appuser run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]