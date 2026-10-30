FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    postgresql-client \
    postgresql \
    postgresql-contrib \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go (will use version from go.mod)
RUN curl -fsSL https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/root/go"
ENV PATH="$GOPATH/bin:$PATH"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Initialize git submodules (needed for embedded docs)
RUN git init && git add . && git submodule update --init --recursive 2>/dev/null || true

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]