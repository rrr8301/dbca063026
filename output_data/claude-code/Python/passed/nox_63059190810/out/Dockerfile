FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_COLOR=1
ENV PATH="/root/.local/bin:$PATH"

# Install system dependencies and Python versions
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libssl-dev \
    libffi-dev \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
    python3.9 \
    python3.9-dev \
    python3.10 \
    python3.10-dev \
    python3.11 \
    python3.11-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Set python3.11 as the default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

WORKDIR /app
COPY repo/ /app/

# Install Nox-under-test
RUN uv pip install --system .

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
