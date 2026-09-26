FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    python3 \
    python3-pip \
    wget \
    unzip \
    net-tools \
    libglib2.0-0 \
    libx11-6 \
    libxss1 \
    libappindicator1 \
    libindicator7 \
    libnss3 \
    libgconf-2-4 \
    fonts-liberation \
    libxrandr2 \
    xdg-utils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Enable IPv6
RUN echo "net.ipv6.conf.all.disable_ipv6 = 0" > /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.disable_ipv6 = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.lo.disable_ipv6 = 0" >> /etc/sysctl.conf

# Install Go 1.26.1
RUN curl -LO https://go.dev/dl/go1.26.1.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.26.1.linux-amd64.tar.gz && \
    rm go1.26.1.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"

# Install Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Deno 1.40.0
RUN curl -fsSL https://github.com/denoland/deno/releases/download/v1.40.0/deno-x86_64-unknown-linux-gnu.zip -o deno.zip && \
    unzip -d /usr/local/bin deno.zip && \
    rm deno.zip && \
    chmod +x /usr/local/bin/deno

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Run build setup if needed (install npm dependencies in scripts folder)
RUN cd /app/scripts && npm ci

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
