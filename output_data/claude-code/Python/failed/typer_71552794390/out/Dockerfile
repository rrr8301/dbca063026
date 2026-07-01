FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV UV_NO_SYNC=true
ENV TERMINAL_WIDTH=3000
ENV _TYPER_FORCE_DISABLE_TERMINAL=1
ENV _TYPER_RUN_INSTALL_COMPLETION_TESTS=1
ENV UV_PYTHON=3.10
ENV UV_RESOLUTION=lowest-direct

RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3-pip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app
COPY repo/ /app/

RUN uv sync --no-dev --group tests

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
