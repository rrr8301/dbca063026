FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/postgres
ENV PG_HOME=/home/postgres/pg18
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    build-essential \
    libreadline-dev \
    zlib1g-dev \
    flex \
    bison \
    git \
    ca-certificates \
    pkg-config \
    libicu-dev \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN sed -i 's/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

# Create postgres user
RUN useradd -m -d /home/postgres postgres && chown -R postgres:postgres /home/postgres

USER postgres

# Clone and build PostgreSQL 18
RUN git clone --depth 1 --branch REL_18_STABLE https://git.postgresql.org/git/postgresql.git /tmp/pg18source \
    && cd /tmp/pg18source \
    && ./configure --prefix=$PG_HOME CFLAGS="-std=gnu99 -ggdb -O0" --enable-cassert \
    && make install -j$(nproc) > /dev/null \
    && cd contrib \
    && cd fuzzystrmatch \
    && make PG_CONFIG=$PG_HOME/bin/pg_config install -j$(nproc) > /dev/null \
    && cd ../pg_trgm \
    && make PG_CONFIG=$PG_HOME/bin/pg_config install -j$(nproc) > /dev/null \
    && rm -rf /tmp/pg18source

WORKDIR /app
COPY --chown=postgres:postgres repo/ /app/

# Build AGE
RUN make PG_CONFIG=$PG_HOME/bin/pg_config COPT=-Werror install -j$(nproc)

# Build pgvector
RUN git clone https://github.com/pgvector/pgvector.git /tmp/pgvector \
    && cd /tmp/pgvector \
    && make PG_CONFIG=$PG_HOME/bin/pg_config install -j$(nproc) > /dev/null \
    && rm -rf /tmp/pgvector

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
