FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app

COPY repo/ /app/

RUN /root/.local/bin/uv venv --allow-existing --seed && \
    /root/.local/bin/uv sync --locked --extra=develop

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
