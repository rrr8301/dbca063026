FROM golang:1.23-alpine

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apk add --no-cache \
    git \
    curl \
    wget \
    ca-certificates \
    build-base \
    make \
    bash \
    gcc \
    musl-dev

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}" \
    GOPATH="/root/go" \
    GOPROXY="https://proxy.golang.org,direct"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]