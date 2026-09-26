FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libssh-dev \
    libltdl-dev \
    apache2-dev \
    libapr1-dev \
    libaprutil1-dev \
    libavahi-client-dev \
    libsqlite3-dev \
    redis-server \
    git \
    cmake \
    ninja-build \
    mongodb \
    && apt-get clean

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]