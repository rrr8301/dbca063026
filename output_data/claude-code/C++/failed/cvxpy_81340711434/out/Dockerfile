FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_OS=ubuntu-22.04
ENV PYTHON_VERSION=3.11
ENV SINGLE_ACTION_CONFIG=False
ENV USE_OPENMP=False

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    pkg-config \
    swig \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/root/.local/bin:${PATH}"

RUN uv venv && \
    . .venv/bin/activate && \
    uv pip install pytest pytest-cov hypothesis "setuptools>65.5.1" && \
    uv pip install scs clarabel osqp highspy && \
    uv pip install scipy numpy

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
