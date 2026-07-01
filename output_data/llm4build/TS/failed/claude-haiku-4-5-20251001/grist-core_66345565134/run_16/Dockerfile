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
    python3-full \
    nodejs \
    npm \
    yarn \
    ca-certificates \
    netcat-openbsd \
    fonts-liberation \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . .

RUN pip install --quiet --break-system-packages virtualenv

CMD ["/bin/bash"]