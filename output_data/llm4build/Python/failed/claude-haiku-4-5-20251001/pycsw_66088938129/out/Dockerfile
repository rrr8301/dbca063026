FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python3-dev \
    python3-pip \
    libgeos-dev \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libz-dev \
    libexpat1 \
    python3-distutils-extra \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install Python dependencies
RUN pip3 install --upgrade setuptools --break-system-packages && \
    pip3 install -r requirements.txt --break-system-packages && \
    pip3 install -r requirements-standalone.txt --break-system-packages && \
    pip3 install -r requirements-pubsub.txt --break-system-packages && \
    pip3 install -r requirements-dev.txt --break-system-packages && \
    pip3 install --upgrade https://github.com/geopython/OWSLib/archive/master.zip --break-system-packages && \
    pip3 install tox --break-system-packages

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]