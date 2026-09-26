FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip && \
    pip install uv

WORKDIR /app

COPY repo/ /app/

ENV UV_NO_SYNC=true
ENV UV_PYTHON=3.14
ENV UV_RESOLUTION=highest

RUN uv sync --no-dev --group tests

RUN mkdir -p coverage

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
