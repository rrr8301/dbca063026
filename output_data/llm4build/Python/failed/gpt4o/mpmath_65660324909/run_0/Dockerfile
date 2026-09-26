FROM ubuntu:24.04

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
    python3.9 \
    python3.9-venv \
    python3.9-dev \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.9 as the default python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# Install pip
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install Python dependencies
RUN pip install --upgrade setuptools pip
RUN pip install --upgrade .[develop,gmpy2,gmp,ci]

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]