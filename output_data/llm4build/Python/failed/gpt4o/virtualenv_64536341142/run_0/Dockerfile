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
    gpg \
    git \
    wget

# Add additional repositories and keys
RUN apt-add-repository ppa:fish-shell/release-4 -y && \
    curl -fsSL https://apt.fury.io/nushell/gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/fury-nushell.gpg && \
    echo "deb https://apt.fury.io/nushell/ /" | tee /etc/apt/sources.list.d/fury.list && \
    apt-get update && apt-get install -y nushell

# Install Python versions
RUN apt-get install -y python3.10 python3.14 python3-pip

# Install uv
RUN pip install uv

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install tox using uv
RUN uv tool install --no-managed-python --python 3.14 "tox>=4.32" --with tox-uv --with .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]