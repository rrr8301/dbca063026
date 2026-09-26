FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always
ENV MISE_TRUSTED_CONFIG_PATHS=/app
ENV MISE_EXPERIMENTAL=1
ENV MISE_LOCKFILE=1
ENV RUST_BACKTRACE=1
ENV PATH="/root/.cargo/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    pkg-config \
    libssl-dev \
    ca-certificates \
    bison \
    direnv \
    fd-find \
    fish \
    python3-venv \
    zsh \
    npm \
    jq \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly

WORKDIR /app

COPY repo/ /app/

RUN cargo build --all-features 2>&1 && \
    echo "Build successful"

RUN echo "/app/target/debug" >> /etc/profile.d/path.sh && \
    /root/.cargo/bin/cargo install --path . --debug 2>&1 || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
