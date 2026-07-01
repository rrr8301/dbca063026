FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
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
    ninja-build \
    lsb-release \
    software-properties-common \
    && apt-get clean

# Install a newer version of CMake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.26.0/cmake-3.26.0-linux-x86_64.sh && \
    chmod +x cmake-3.26.0-linux-x86_64.sh && \
    ./cmake-3.26.0-linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-3.26.0-linux-x86_64.sh

# Add MongoDB repository and install MongoDB
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt-get update && apt-get install -y mongodb-org && apt-get clean

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]