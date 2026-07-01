FROM ubuntu@sha256:4e0171b9275e12d375863f2b3ae9ce00a4c53ddda176bd55868df97ac6f21a6e

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Set custom PyPI mirror
ENV UV_DEFAULT_INDEX="https://us-python.pkg.dev/ml-oss-artifacts-published/pypi-mirror/simple"
ENV PIP_INDEX_URL="https://us-python.pkg.dev/ml-oss-artifacts-published/pypi-mirror/simple"

# Update apt and install OS-level dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    git \
    build-essential \
    cmake \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.14
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
    python3.14 \
    python3.14-venv \
    python3.14-dev \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.14 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.14 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.14 1

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install uv and project dependencies
RUN python3.14 -m pip install --upgrade pip && \
    python3.14 -m pip install uv~=0.5.30 && \
    uv pip install --system .[minimum-jaxlib] -r build/test-requirements.txt

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]