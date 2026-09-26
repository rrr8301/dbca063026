FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PY_COLORS=1
ENV PATH="/root/.local/bin:/root/.cargo/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

# Install uv using the official installer
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Python 3.10 and dependencies
RUN /root/.local/bin/uv python install 3.10

# Sync dependencies
RUN /root/.local/bin/uv sync --locked

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
