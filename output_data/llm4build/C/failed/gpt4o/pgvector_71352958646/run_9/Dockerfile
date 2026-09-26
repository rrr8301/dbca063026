FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    gnupg \
    git \
    make \
    sudo \
    wget \
    curl \
    gcc \
    libpq-dev \
    software-properties-common

# Add PostgreSQL APT repository
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ noble-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install PostgreSQL
RUN apt-get update && apt-get install -y \
    postgresql-15 \
    postgresql-server-dev-15

# Configure PostgreSQL to use md5 authentication
RUN echo "host all all 127.0.0.1/32 md5" >> /etc/postgresql/15/main/pg_hba.conf

# Create a PostgreSQL user
RUN service postgresql start && \
    sudo -u postgres psql -c "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" && \
    sudo -u postgres psql -c "ALTER USER docker WITH PASSWORD 'docker';"

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]