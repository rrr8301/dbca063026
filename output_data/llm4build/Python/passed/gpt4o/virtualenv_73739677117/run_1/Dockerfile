FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    snapd \
    fish \
    csh \
    curl \
    wget \
    git

# Add repository for nushell
RUN curl -fsSL https://apt.fury.io/nushell/gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/fury-nushell.gpg && \
    echo "deb https://apt.fury.io/nushell/ /" | tee /etc/apt/sources.list.d/fury.list && \
    apt-get update && apt-get install -y nushell

# Install Python 3.12
RUN apt-get install -y python3.12 python3.12-venv python3.12-dev

# Install pip and tox
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 && \
    pip install "tox>=4.45" tox-uv

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]