FROM ubuntu:24.04

# Set timezone to avoid tzdata prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies and add PostgreSQL repository
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    make \
    gcc \
    curl \
    gnupg \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Add PostgreSQL official repository
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install PostgreSQL 19
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-19 \
    postgresql-server-dev-19 \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]