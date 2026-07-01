FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_COLOR=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    brz \
    subversion \
    python3.14 \
    python3.14-venv \
    python3.14-dev \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set python3.14 as the default python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.14 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.14 1

# Install pip for python3.14
RUN python3.14 -m ensurepip --upgrade

# Create app directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install nox
RUN python3.14 -m pip install --upgrade pip && python3.14 -m pip install nox

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
