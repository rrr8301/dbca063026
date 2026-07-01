FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    liblzma-dev \
    git \
    curl \
    ca-certificates \
    build-essential \
    pkg-config \
    libssl-dev && \ 
    # Clean up APT when done
    rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Source the Rust environment
RUN echo 'source $HOME/.cargo/env' >> /root/.bashrc

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install just and nextest with --locked for nextest
RUN /bin/bash -c "source $HOME/.cargo/env && cargo install just && cargo install --locked cargo-nextest"

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]