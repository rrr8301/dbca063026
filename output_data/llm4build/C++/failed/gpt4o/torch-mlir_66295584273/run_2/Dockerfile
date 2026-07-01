FROM ubuntu:20.04

# Set timezone to avoid tzdata prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies and add PPA for Python 3.11
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
    git \
    ccache \
    ninja-build \
    wget \
    curl \
    cmake \
    make \
    g++ \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip

# Set up work directory
WORKDIR /workspace

# Copy the repository into the container
COPY . .

# Install Python dependencies
RUN python3.11 -m pip install --upgrade pip && \
    python3.11 -m pip install -r requirements.txt && \
    python3.11 -m pip install -r build-requirements.txt

# Copy and set permissions for run.sh
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]