FROM golang:1.24-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python3-dev \
    python3-setuptools \
    python3-pip \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

ENV PATH=/usr/local/go/bin:$PATH \
    GOPATH=/root/go \
    GOARCH=amd64 \
    CGO_ENABLED=1 \
    SKIP_PYTHON_BINDINGS_TESTS=0

# Install Python packages
RUN pip install --break-system-packages -U wheel pytest setuptools

WORKDIR /app

COPY repo/ /app/

RUN make install.dependencies

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
