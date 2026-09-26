FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    gpg \
    software-properties-common \
    build-essential \
    python3-dev \
    python3-pip \
    python3.12 \
    python3.12-dev \
    python3.14 \
    python3.14-dev \
    snapd \
    csh \
    && rm -rf /var/lib/apt/lists/*

# Add fish shell PPA and install fish
RUN add-apt-repository ppa:fish-shell/release-4 -y && \
    apt-get update && \
    apt-get install -y fish && \
    rm -rf /var/lib/apt/lists/*

# Add nushell repository and install nushell
RUN curl -fsSL https://apt.fury.io/nushell/gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/fury-nushell.gpg && \
    echo "deb https://apt.fury.io/nushell/ /" | tee /etc/apt/sources.list.d/fury.list && \
    apt-get update && \
    apt-get install -y nushell && \
    rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip3 install uv

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]