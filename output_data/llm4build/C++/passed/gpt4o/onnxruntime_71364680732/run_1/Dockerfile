# Dockerfile
FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    coreutils \
    ninja-build \
    make \
    build-essential \
    software-properties-common \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA for Python 3.14
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.14 python3.14-distutils && \
    rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.14
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.14

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Set up work directory
WORKDIR /app

# Copy the repository
COPY . .

# Install Python dependencies
RUN python3.14 -m pip install --upgrade pip && \
    python3.14 -m pip install -r requirements-dev.txt && \
    python3.14 -m pip install -r tools/ci_build/github/linux/docker/scripts/requirements.txt

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]