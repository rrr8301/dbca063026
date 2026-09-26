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
    p7zip-full \
    build-essential \
    jq && \
    rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Build the Rust application
RUN cargo build --release

# Determine the binary name
RUN cargo metadata --format-version=1 --no-deps | jq -r '.packages[0].name' > /app/binary_name.txt

# Ensure the binary is built and exists
RUN BINARY_NAME=$(cat /app/binary_name.txt) && \
    test -f /app/target/release/$BINARY_NAME

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]