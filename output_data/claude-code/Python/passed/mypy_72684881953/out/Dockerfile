FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TOX_SKIP_MISSING_INTERPRETERS=False
ENV VIRTUALENV_SYSTEM_SITE_PACKAGES=0
ENV FORCE_COLOR=1
ENV PY_COLORS=1
ENV TERM=xterm-color
ENV MYPY_FORCE_COLOR=1
ENV MYPY_FORCE_TERMINAL_WIDTH=200
ENV PYTEST_ADDOPTS=--color=yes

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN python3.11 -m pip install --break-system-packages tox==4.26.0

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
