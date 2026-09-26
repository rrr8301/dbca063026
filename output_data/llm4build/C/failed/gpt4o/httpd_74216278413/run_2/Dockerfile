FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    cpanminus libtool-bin libapr1-dev libaprutil1-dev \
    liblua5.3-dev libbrotli-dev libcurl4-openssl-dev \
    libnghttp2-dev libjansson-dev libpcre2-dev gdb \
    perl-doc libsasl2-dev curl git python3-pytest \
    python3-cryptography python3-requests python3-multipart \
    python3-filelock python3-websockets nghttp2-client \
    automake autoconf

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]