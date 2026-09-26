FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libreadline-dev \
    zlib1g-dev \
    flex \
    bison \
    git \
    gcc \
    g++ \
    make \
    curl \
    wget \
    pkg-config \
    libicu-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libedit-dev \
    libperl-dev \
    libpython3-dev \
    tcl-dev \
    uuid-dev \
    locales

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create a non-root user
RUN useradd -ms /bin/bash postgres_user

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Change ownership of /app to the non-root user
RUN chown -R postgres_user:postgres_user /app

# Switch to the non-root user
USER postgres_user

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]