FROM ubuntu:24.04

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3-dev \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    yarn \
    ca-certificates \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . .

RUN pip install --quiet virtualenv

CMD ["/bin/bash"]