FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    git \
    curl \
    wget \
    libbz2-dev \
    libssl-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    zlib1g-dev \
    xz-utils \
    tk-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv dependencies
RUN apt-get update && apt-get install -y \
    make \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv
RUN git clone https://github.com/pyenv/pyenv.git /root/.pyenv
ENV PATH="/root/.pyenv/bin:$PATH"

# Install Python 3.14t (free-threaded) using pyenv
RUN eval "$(pyenv init --path)" && \
    PYTHON_CONFIGURE_OPTS="--with-optimizations --disable-gil" \
    pyenv install 3.14t && \
    pyenv global 3.14t

# Set up PATH to use pyenv Python
ENV PATH="/root/.pyenv/shims:/root/.pyenv/bin:$PATH"

# Install pip and upgrade setuptools
RUN python -m ensurepip --upgrade && python -m pip install --upgrade pip setuptools wheel

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# Set up the working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install build tools
RUN uv pip install --system setuptools wheel build

# Install dependencies
RUN uv pip install --system -e .[test]
RUN uv pip install --system check-manifest pytest-cov pytest

# Copy and set up run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
