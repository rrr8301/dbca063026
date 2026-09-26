FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    make \
    gcc \
    g++ \
    python3 \
    python3-dev \
    python3-setuptools \
    python3-pip \
    golang-go \
    && rm -rf /var/lib/apt/lists/*

# Set Go environment variables
ENV GOARCH="amd64" \
    CGO_ENABLED="1" \
    PATH="/usr/local/go/bin:$PATH"

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install Python packages
RUN pip install --no-cache-dir --break-system-packages pytest setuptools wheel

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]