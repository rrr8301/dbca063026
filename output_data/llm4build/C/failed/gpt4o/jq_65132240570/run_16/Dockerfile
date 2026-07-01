FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    autoconf \
    automake \
    libtool \
    make \
    gcc \
    g++ \
    pkg-config \
    libonig-dev \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    file \
    curl \
    gettext \
    m4 \
    libncurses5-dev \
    libncursesw5-dev \
    libffi-dev \
    libgmp-dev \
    ca-certificates \
    xz-utils \
    bison \
    flex \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]