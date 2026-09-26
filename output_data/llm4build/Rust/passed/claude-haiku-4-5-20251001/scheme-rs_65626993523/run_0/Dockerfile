FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set cargo color output
ENV CARGO_TERM_COLOR=always

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    libllvm18 \
    llvm-18 \
    llvm-18-dev \
    libpolly-18-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust stable toolchain with clippy and rustfmt
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    -y \
    --default-toolchain stable \
    --component clippy,rustfmt

# Add cargo to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Set entrypoint
COPY /run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]