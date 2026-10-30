FROM python:3.13-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV COLUMNS=150
ENV UV_FROZEN=true
ENV FORCE_COLOR=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Rust stable
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

ENV PATH=/root/.cargo/bin:/root/.local/bin:$PATH

WORKDIR /app

COPY repo/ /app/

# Install dependencies
RUN . /root/.local/bin/env && \
    uv sync --all-packages --all-extras --group testing-extra

# Build debug version and run tests
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
