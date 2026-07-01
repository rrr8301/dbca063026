FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    libssl-dev \
    libffi-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libgdbm-dev \
    uuid-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.14-dev from python.org
RUN cd /tmp && \
    wget -q https://www.python.org/ftp/python/3.14.0/Python-3.14.0a1.tar.xz && \
    tar xf Python-3.14.0a1.tar.xz && \
    cd Python-3.14.0a1 && \
    ./configure --prefix=/usr/local --enable-optimizations && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/Python-3.14.0a1*

# Set python and python3 to point to the new version
RUN ln -sf /usr/local/bin/python3.14 /usr/bin/python && \
    ln -sf /usr/local/bin/python3.14 /usr/bin/python3

# Install pip
RUN /usr/local/bin/python3.14 -m pip install --upgrade pip setuptools wheel

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app

COPY repo/ /app/

# Install Python dependencies for dev version
RUN uv pip install --system --prerelease=allow setuptools wheel build && \
    uv pip install --system --prerelease=allow --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple -e .[test] && \
    uv pip install --system --prerelease=allow --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple check-manifest pytest-cov

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
