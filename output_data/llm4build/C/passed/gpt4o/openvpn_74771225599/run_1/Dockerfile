FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    liblzo2-dev \
    libpam0g-dev \
    liblz4-dev \
    libcap-ng-dev \
    libnl-genl-3-dev \
    linux-libc-dev \
    man2html \
    libcmocka-dev \
    python3-docutils \
    libtool \
    automake \
    autoconf \
    libssl-dev \
    libpkcs11-helper1-dev \
    softhsm2 \
    gnutls-bin \
    git \
    make \
    gcc \
    pkg-config  # Added pkg-config

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]