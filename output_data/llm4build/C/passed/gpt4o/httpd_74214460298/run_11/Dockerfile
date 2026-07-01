FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    cpanminus libtool-bin libapr1-dev libaprutil1-dev \
    liblua5.3-dev libbrotli-dev libcurl4-openssl-dev \
    libnghttp2-dev libjansson-dev libpcre2-dev gdb \
    perl-doc libsasl2-dev curl git python3-pip \
    automake autoconf sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install pytest cryptography requests multipart filelock websockets

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy and set permissions for run.sh
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]