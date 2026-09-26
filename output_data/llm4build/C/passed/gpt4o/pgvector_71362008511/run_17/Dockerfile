FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    git \
    make \
    sudo \
    lsb-release \
    ca-certificates \
    gcc \
    build-essential \
    postgresql-client

# Add PostgreSQL APT repository
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | tee /etc/apt/trusted.gpg.d/pgdg.asc && \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install PostgreSQL 15 and development files
RUN apt-get update && apt-get install -y \
    postgresql-15 \
    postgresql-server-dev-15

# Configure PostgreSQL to use password authentication
RUN sed -i "s/peer/md5/" /etc/postgresql/15/main/pg_hba.conf && \
    sed -i "s/ident/md5/" /etc/postgresql/15/main/pg_hba.conf

# Ensure PostgreSQL starts with the correct configuration
RUN echo "listen_addresses='*'" >> /etc/postgresql/15/main/postgresql.conf

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]