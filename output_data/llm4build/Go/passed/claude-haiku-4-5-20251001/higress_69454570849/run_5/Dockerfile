FROM golang:1.24-alpine

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
    GOPROXY="https://proxy.golang.org,direct" \
    GOTOOLCHAIN="local"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Initialize and update git submodules if they exist
RUN git init && \
    git config user.email "builder@local" && \
    git config user.name "Builder" && \
    git add . && \
    git submodule update --init --recursive 2>/dev/null || true

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]