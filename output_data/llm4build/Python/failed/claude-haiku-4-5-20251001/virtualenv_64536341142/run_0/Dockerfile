FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    gpg \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3.14 \
    python3.14-dev \
    python3.14-venv \
    software-properties-common \
    snapd \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Add fish shell PPA and install shells
RUN apt-add-repository ppa:fish-shell/release-4 -y && \
    curl -fsSL https://apt.fury.io/nushell/gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/fury-nushell.gpg && \
    echo "deb https://apt.fury.io/nushell/ /" | tee /etc/apt/sources.list.d/fury.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    csh \
    fish \
    nushell \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Set PATH to include uv
ENV PATH="/root/.cargo/bin:$PATH"

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]