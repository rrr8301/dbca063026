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

# Copy repository with submodules
COPY . .

# Initialize git repository and configure it
RUN git init && \
    git config user.email "builder@local" && \
    git config user.name "Builder" && \
    git add . && \
    git commit -m "Initial commit" --allow-empty || true

# Initialize and update git submodules with proper error handling
RUN git submodule update --init --recursive || true

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh && \
    dos2unix /workspace/run.sh || sed -i 's/\r$//' /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]