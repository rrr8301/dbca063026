FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    make \
    g++ \
    cmake \
    ninja-build \
    clang \
    cargo \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip && \
    apt-get clean

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install Python dependencies
RUN pip install -r requirements-dev.txt

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]