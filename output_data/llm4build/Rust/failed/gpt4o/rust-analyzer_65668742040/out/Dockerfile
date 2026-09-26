FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup update --no-self-update stable && \
    rustup default stable && \
    rustup component add --toolchain stable rust-src rustfmt && \
    rustup toolchain install nightly --profile minimal --component rustfmt

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install nextest and cargo-machete with --locked for nextest
RUN cargo install --locked cargo-nextest && \
    cargo install cargo-machete

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]