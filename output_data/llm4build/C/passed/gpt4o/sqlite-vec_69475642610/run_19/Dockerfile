FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    make \
    curl \
    wget \
    cmake \
    ninja-build \
    g++ \
    clang \
    cargo \
    unzip \
    gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Attempt to install uv using a fallback method if the primary method fails
RUN curl -sSL https://correct-url.com/install-uv.sh | bash || \
    (echo "Failed to download install-uv.sh due to network issues, attempting fallback installation" && \
    git clone https://github.com/astral-sh/uv.git && \
    cd uv && \
    cargo install --path .)

# Ensure uv is installed and available in PATH
ENV PATH="/root/.cargo/bin:/usr/local/bin:$PATH"

# Verify uv installation
RUN command -v uv || (echo "uv installation failed" && exit 1)

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]