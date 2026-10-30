FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PY_COLORS=1

RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

RUN /root/.local/bin/uv sync --locked

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
