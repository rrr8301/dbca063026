FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    gnupg \
    git \
    make \
    wget \
    curl \
    gcc \
    libpq-dev \
    software-properties-common

# Add PostgreSQL APT repository
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update

# Install PostgreSQL
RUN apt-get install -y \
    postgresql-15 \
    postgresql-server-dev-15

# Configure PostgreSQL to use trust authentication for local connections
RUN sed -i "s/peer/trust/g" /etc/postgresql/15/main/pg_hba.conf && \
    sed -i "s/md5/trust/g" /etc/postgresql/15/main/pg_hba.conf

# Start PostgreSQL service and create a user and database
RUN service postgresql start && \
    su - postgres -c "psql -c \"CREATE USER docker WITH SUPERUSER PASSWORD 'docker';\"" && \
    su - postgres -c "psql -c \"CREATE DATABASE contrib_regression OWNER docker;\"" && \
    service postgresql stop

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]