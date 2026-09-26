FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.13
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    python3.13 \
    python3.13-dev \
    python3.13-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip3 install --no-cache-dir uv

WORKDIR /app
COPY repo/ /app/

RUN uv venv --python 3.13
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN uv sync --locked --all-groups

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
