FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PG_VERSION=18

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    lsb-release \
    gnupg \
    wget \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    perl \
    pkg-config \
    libicu-dev \
    bison \
    flex

RUN wget -q https://ftp.postgresql.org/pub/source/v$PG_VERSION.0/postgresql-$PG_VERSION.0.tar.gz && \
    tar xf postgresql-$PG_VERSION.0.tar.gz && \
    cd postgresql-$PG_VERSION.0 && \
    ./configure --prefix=/usr/local/pgsql && \
    make && \
    make install && \
    cd .. && \
    rm -rf postgresql-$PG_VERSION.0*

RUN useradd -m -s /bin/bash postgres || true && \
    mkdir -p /usr/local/pgsql/data && \
    chown -R postgres:postgres /usr/local/pgsql

ENV PATH="/usr/local/pgsql/bin:$PATH"

RUN mkdir -p /app
WORKDIR /app

COPY repo/ /app/

RUN chown -R postgres:postgres /app

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
