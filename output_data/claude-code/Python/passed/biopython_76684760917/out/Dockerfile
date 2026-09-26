FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    gcc \
    g++ \
    make \
    mysql-server \
    wget \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y python3.14 python3.14-dev python3.14-venv \
    && apt-get clean

# Set Python 3.14 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.14 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.14 1

# Install pip
RUN curl https://bootstrap.pypa.io/get-pip.py | python3.14

WORKDIR /app

# Copy repository
COPY repo/ /app/

# Install Python packaging tools
RUN python -m pip install --upgrade pip setuptools wheel build

# Install CI dependencies
RUN python -m pip install --upgrade --upgrade-strategy eager -r ci-dependencies.txt

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
