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

# Install uv
# Replace the URL with the actual URL of the install script
RUN curl -sSL https://correct-url.com/install-uv.sh | bash || (echo "Failed to download install-uv.sh due to network issues" && exit 1)

# Ensure uv is installed and available in PATH
ENV PATH="/usr/local/bin:$PATH"

# Verify uv installation
RUN uv --version || (echo "uv installation failed" && exit 1)

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]