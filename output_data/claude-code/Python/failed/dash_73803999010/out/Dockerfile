FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    npm \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

RUN python -m pip install --upgrade pip setuptools wheel

WORKDIR /app

COPY repo/ /app/

RUN npm install -g n && n 24

RUN npm ci

RUN python -m pip install --upgrade pip wheel && \
    python -m pip install "setuptools<80.0.0" && \
    python -m pip install build

RUN python -m pip install -r requirements/testing.txt && \
    python -m pip install -r requirements/ci.txt && \
    python -m pip install -r requirements/dev.txt

RUN npm run cibuild

RUN python -m build --sdist --wheel && \
    mkdir -p packages && \
    cp dist/*.whl packages/

RUN python -m pip install --upgrade pip wheel && \
    python -m pip install "setuptools<80.0.0" && \
    find packages -name dash-*.whl -print -exec sh -c 'pip install "{}[ci,testing,dev]"' \;

RUN npm run setup-tests.py

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
