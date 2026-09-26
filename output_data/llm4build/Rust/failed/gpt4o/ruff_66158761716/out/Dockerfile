# Dockerfile
FROM rust:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy the repository into the container
COPY . .

# Install Rust tools separately to handle potential issues
RUN cargo install cargo-insta

# Install cargo-nextest separately and handle potential issues
RUN cargo install cargo-nextest || true

# Install mold separately and handle potential issues
RUN cargo install mold || true

# Install uv
RUN curl -sSL https://astral.sh/uv/install.sh | sh

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]