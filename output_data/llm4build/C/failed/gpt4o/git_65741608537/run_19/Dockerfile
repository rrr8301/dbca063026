FROM ubuntu:rolling

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    g++ \
    libc6-dev \
    meson \
    sudo \
    make \
    cmake \
    ninja-build \
    bash \
    libssl-dev \  # Added OpenSSL development libraries
    curl          # Added curl to resolve curl-config issue
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy the repository into the container
COPY . .

# Ensure scripts have executable permissions
RUN chmod +x /workspace/ci/install-dependencies.sh /workspace/ci/run-build-and-tests.sh

# Copy and set permissions for run.sh
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Create builder user and set permissions
RUN useradd builder --create-home && chown -R builder /workspace

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]