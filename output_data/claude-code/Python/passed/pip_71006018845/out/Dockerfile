FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_COLOR=1

# Install system dependencies including Python 3.13
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    software-properties-common \
    brz \
    subversion \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA and install Python 3.13
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.13 \
    python3.13-dev \
    python3.13-venv \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.13 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.13 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1

# Install pip for Python 3.13
RUN python -m ensurepip --upgrade

# Set working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install nox
RUN python -m pip install nox

# Copy and prepare the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
