FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libreadline-dev \
    libzstd-dev \
    bison \
    flex \
    pkg-config \
    libicu-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone and compile PostgreSQL from git
WORKDIR /build
RUN git clone https://github.com/postgres/postgres.git

WORKDIR /build/postgres
RUN ./configure --prefix=/usr/local/pgsql --with-icu && \
    make && \
    make install

# Create postgres user and initialize
RUN useradd -m postgres || true && \
    mkdir -p /usr/local/pgsql/data && \
    chown postgres:postgres /usr/local/pgsql/data || true

ENV PATH=/usr/local/pgsql/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/pgsql/lib:$LD_LIBRARY_PATH

WORKDIR /app
COPY repo/ /app/

RUN make \
    PG_CFLAGS="-DUSE_ASSERT_CHECKING -Wall -Wextra -Werror -Wno-unused-parameter -Wno-sign-compare -Wno-missing-field-initializers"

RUN export PG_CONFIG=$(which pg_config) && \
    make install

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
