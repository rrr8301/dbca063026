FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HF_HOME=.cache/huggingface

RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN python3.11 -m pip install --upgrade pip && \
    python3.11 -m pip install setuptools && \
    python3.11 -m pip install -U git+https://github.com/huggingface/transformers.git && \
    python3.11 -m pip install -e .[test]

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
