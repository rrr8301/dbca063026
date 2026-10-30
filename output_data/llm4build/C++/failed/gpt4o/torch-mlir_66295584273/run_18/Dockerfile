FROM ubuntu:20.04

# Set timezone to avoid tzdata prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    git \
    ccache \
    ninja-build \
    wget \
    curl \
    cmake \
    make \
    g++ \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-pip

# Install Python 3.11 from source
RUN wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tgz && \
    tar xzf Python-3.11.0.tgz && \
    cd Python-3.11.0 && \
    ./configure --enable-optimizations && \
    make -j 4 && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.11.0 Python-3.11.0.tgz

# Set up work directory
WORKDIR /workspace

# Copy the repository into the container
COPY . .

# Ensure the requirements files are in the correct location
# Adjust the path if necessary
COPY requirements.txt /workspace/requirements.txt
COPY build-requirements.txt /workspace/build-requirements.txt

# Install Python dependencies
RUN python3.11 -m pip install --upgrade pip && \
    python3.11 -m pip install -r /workspace/requirements.txt && \
    python3.11 -m pip install -r /workspace/build-requirements.txt || true

# Copy and set permissions for run.sh
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]