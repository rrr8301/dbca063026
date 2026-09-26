FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    clang \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Protoc
RUN apt-get update && apt-get install -y protobuf-compiler

# Install mold
RUN curl -L https://github.com/rui314/mold/releases/download/v1.0.1/mold-1.0.1-x86_64-linux.tar.gz -o mold.tar.gz \
    && tar xzf mold.tar.gz -C /usr/local/bin --strip-components=1 \
    && rm mold.tar.gz

# Install nextest
RUN cargo install cargo-nextest

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]