FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN apt-add-repository ppa:deadsnakes/ppa -y && \
    apt-add-repository ppa:fish-shell/release-4 -y && \
    curl -fsSL https://apt.fury.io/nushell/gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/fury-nushell.gpg && \
    echo "deb https://apt.fury.io/nushell/ /" | tee /etc/apt/sources.list.d/fury.list && \
    apt-get update && apt-get install -y \
    snapd \
    fish \
    csh \
    nushell \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3.14 \
    python3.14-venv \
    python3.14-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app
COPY repo/ /app/

RUN git fetch --force --tags https://github.com/pypa/virtualenv.git

RUN uv tool install --no-managed-python --python 3.14 "tox>=4.32" --with tox-uv --with .

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
