FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    make \
    python3 \
    python3-pip \
    sudo \
    build-essential \
    libcapstone-dev \
    libuv1-dev \
    pkg-config \
    autoconf \
    automake \
    libtool \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python packages
RUN python3 -m pip install --upgrade pip && \
    pip3 install --user r2pipe wheel

# Create a non-root user
RUN useradd -ms /bin/bash radareuser

# Switch to the non-root user
USER radareuser

# Create work directory
WORKDIR /home/radareuser/app

# Copy repository contents
COPY --chown=radareuser:radareuser . .

# Ensure sys/install.sh and configure are executable
RUN chmod +x sys/install.sh && chmod +x configure

# Copy run.sh and make it executable
COPY --chown=radareuser:radareuser run.sh /home/radareuser/app/run.sh
RUN chmod +x /home/radareuser/app/run.sh

# Set entrypoint
ENTRYPOINT ["/home/radareuser/app/run.sh"]