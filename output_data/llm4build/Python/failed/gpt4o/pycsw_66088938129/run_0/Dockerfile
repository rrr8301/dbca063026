FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgeos-dev \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libz-dev \
    libexpat1 \
    python3-distutils-extra \
    git \
    curl \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Install Python 3.12
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.12 python3.12-venv python3.12-dev && \
    rm -rf /var/lib/apt/lists/*

# Install pip and Python packages
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 && \
    pip3 install setuptools tox

# Create work directory
WORKDIR /app

# Copy repository
COPY . /app

# Configure git
RUN git config --global --add safe.directory '*'

# Install Python dependencies
RUN pip3 install -r requirements.txt && \
    pip3 install -r requirements-standalone.txt && \
    pip3 install -r requirements-pubsub.txt && \
    pip3 install -r requirements-dev.txt && \
    pip3 install --upgrade https://github.com/geopython/OWSLib/archive/master.zip

# Copy run.sh and set as entrypoint
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh
ENTRYPOINT ["/app/run.sh"]