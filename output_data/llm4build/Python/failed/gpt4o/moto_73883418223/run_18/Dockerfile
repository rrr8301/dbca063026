FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    sudo \
    curl \
    wget \
    make \
    cmake \
    g++ \
    ninja-build \
    clang \
    cargo \
    python3.11 \
    python3.11-venv \
    python3-pip

# Set Python 3.11 as the default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Create work directory
WORKDIR /app

# Ensure the requirements file is present
COPY requirements-dev.txt /app/

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install -r /app/requirements-dev.txt
RUN pip install pytest-github-actions-annotate-failures

# Copy the rest of the repository
COPY . /app/

# Ensure run.sh is in the correct location and make it executable
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]