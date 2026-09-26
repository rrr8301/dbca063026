FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    gcc-arm-linux-gnueabihf \
    gcc-aarch64-linux-gnu \
    git \
    curl \
    make \
    xz-utils \
    p7zip-full \
    build-essential  # Added to provide the `cc` linker

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install cross if needed
RUN if [ "${USE_CROSS}" = "true" ]; then \
    cargo install cross --version 0.2.5; \
    fi

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]