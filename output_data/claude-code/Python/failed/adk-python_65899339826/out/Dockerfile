FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/root/.local/bin:$PATH

RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    git \
    && add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.13 \
    python3.13-venv \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

RUN /root/.local/bin/uv venv .venv && \
    /root/.local/bin/uv sync --extra test

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
