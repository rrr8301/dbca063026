FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    clang \
    pkg-config \
    flex \
    gcc \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install pipx && \
    pipx install meson ninja && \
    pipx ensurepath

ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
