# Use the base image
FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    make \
    g++ \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    curl \
    wget \
    && apt-get clean

# Create a virtual environment
RUN python3 -m venv /opt/venv

# Activate the virtual environment and upgrade pip
RUN /opt/venv/bin/pip install --upgrade pip

# Create work directory
WORKDIR /app

# Copy the repository into the container
COPY . .

# Install Python dependencies in the virtual environment
RUN /opt/venv/bin/pip install --no-cache-dir \
    pybind11==3.0 \
    cmake==3.30.0 \
    ninja==1.11.1 \
    pytest \
    scikit-build-core \
    setuptools_scm

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]