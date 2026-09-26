FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    libreadline-dev \
    zlib1g-dev \
    flex \
    bison \
    git \
    perl \
    pkg-config \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r postgres && useradd -r -g postgres postgres

WORKDIR /app

COPY repo/ /app/

RUN chown -R postgres:postgres /app

RUN git clone --depth 1 --branch REL_18_STABLE https://git.postgresql.org/git/postgresql.git /tmp/pg18source && \
    cd /tmp/pg18source && \
    ./configure --prefix=/usr/local/pg18 CFLAGS="-std=gnu99 -ggdb -O0" --enable-cassert && \
    make install -j$(nproc) > /dev/null && \
    cd contrib && \
    cd fuzzystrmatch && \
    make PG_CONFIG=/usr/local/pg18/bin/pg_config install -j$(nproc) > /dev/null && \
    cd ../pg_trgm && \
    make PG_CONFIG=/usr/local/pg18/bin/pg_config install -j$(nproc) > /dev/null && \
    chown -R postgres:postgres /usr/local/pg18

ENV PATH="/usr/local/pg18/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/pg18/lib:${LD_LIBRARY_PATH}"
ENV PG_CONFIG=/usr/local/pg18/bin/pg_config

RUN cd /app && make PG_CONFIG=/usr/local/pg18/bin/pg_config install -j$(nproc)

RUN git clone https://github.com/pgvector/pgvector.git /tmp/pgvector && \
    cd /tmp/pgvector && \
    make PG_CONFIG=/usr/local/pg18/bin/pg_config install -j$(nproc) > /dev/null

COPY run.sh /run.sh
RUN chmod +x /run.sh

USER postgres

ENTRYPOINT ["/run.sh"]
