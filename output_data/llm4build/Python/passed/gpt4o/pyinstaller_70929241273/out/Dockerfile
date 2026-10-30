FROM ubuntu:22.04

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
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    pkg-config \
    libcairo2-dev \
    libgirepository1.0-dev \
    libffi-dev \
    libglib2.0-dev \
    gir1.2-glib-2.0 \
    meson \
    gobject-introspection \
    libgirepository1.0-dev \  # Added missing package
    && rm -rf /var/lib/apt/lists/*

# Set up Python environment
RUN python3.11 -m pip install --upgrade pip

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Install Python dependencies
RUN python3.11 -m pip install --upgrade hatchling
RUN python3.11 -m pip install --progress-bar=off --upgrade --requirement tests/requirements-base.txt
RUN python3.11 -m pip install --progress-bar=off --upgrade --requirement tests/requirements-libraries.txt

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]