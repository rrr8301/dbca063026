FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create /nix directory manually
RUN mkdir -m 0755 /nix && chown root /nix

# Install Nix using a Docker-compatible method
RUN addgroup --system nixbld && \
    for i in $(seq 1 10); do \
        useradd -m -s /bin/false -g nixbld nixbld$i; \
    done && \
    curl -L https://nixos.org/nix/install -o install-nix.sh && \
    sh install-nix.sh --no-daemon && \
    rm install-nix.sh

# Set Nix environment variables
ENV USER=root
ENV PATH=/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/root/.cargo/bin:$PATH
ENV NIX_PATH=/nix/var/nix/profiles/per-user/root/channels

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install just
RUN /root/.cargo/bin/cargo install just

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]